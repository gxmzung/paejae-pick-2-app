import os
import random
import smtplib
import time
from email.mime.text import MIMEText
from typing import Dict

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr


app = FastAPI(title="PaejaePick Auth Server", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


CODE_TTL_SECONDS = 600
RESEND_COOLDOWN_SECONDS = 60

_codes: Dict[str, dict] = {}


class RequestCodeBody(BaseModel):
    email: EmailStr


class VerifyCodeBody(BaseModel):
    email: EmailStr
    code: str


def now_seconds() -> int:
    return int(time.time())


def normalize_email(email: str) -> str:
    return email.strip().lower()


def ensure_school_email(email: str) -> None:
    if not email.endswith("@pcu.ac.kr"):
        raise HTTPException(
            status_code=400,
            detail="학교 이메일(@pcu.ac.kr)만 사용할 수 있습니다.",
        )


def make_code() -> str:
    return f"{random.randint(0, 999999):06d}"


def smtp_configured() -> bool:
    required = [
        "SMTP_HOST",
        "SMTP_PORT",
        "SMTP_USER",
        "SMTP_PASSWORD",
        "SMTP_FROM",
    ]
    return all(os.getenv(k) for k in required)


def send_email(to_email: str, code: str) -> None:
    subject = "[배재Pick] 이메일 인증번호"
    body = (
        f"배재Pick 이메일 인증번호는 {code} 입니다.\n"
        f"(유효시간: 10분)\n\n"
        f"본인이 요청하지 않았다면 이 메일을 무시해도 됩니다."
    )

    if not smtp_configured():
        print("")
        print("========== DEV EMAIL AUTH CODE ==========")
        print(f"TO: {to_email}")
        print(f"CODE: {code}")
        print("SMTP 설정이 없어서 실제 메일은 발송하지 않았습니다.")
        print("=========================================")
        print("")
        return

    host = os.environ["SMTP_HOST"]
    port = int(os.environ["SMTP_PORT"])
    user = os.environ["SMTP_USER"]
    password = os.environ["SMTP_PASSWORD"]
    from_email = os.environ["SMTP_FROM"]

    msg = MIMEText(body, _charset="utf-8")
    msg["Subject"] = subject
    msg["From"] = from_email
    msg["To"] = to_email

    with smtplib.SMTP_SSL(host, port) as server:
        server.login(user, password)
        server.sendmail(from_email, [to_email], msg.as_string())


@app.get("/health")
def health():
    return {
        "ok": True,
        "service": "paejae-pick-auth",
        "smtpConfigured": smtp_configured(),
    }


@app.post("/auth/request-code")
def request_code(body: RequestCodeBody):
    email = normalize_email(body.email)
    ensure_school_email(email)

    current = now_seconds()
    saved = _codes.get(email)

    if saved and current - saved["created_at"] < RESEND_COOLDOWN_SECONDS:
        remain = RESEND_COOLDOWN_SECONDS - (current - saved["created_at"])
        raise HTTPException(
            status_code=429,
            detail=f"인증번호는 {remain}초 후 다시 요청할 수 있습니다.",
        )

    code = make_code()

    _codes[email] = {
        "code": code,
        "created_at": current,
        "expires_at": current + CODE_TTL_SECONDS,
        "attempts": 0,
    }

    try:
        send_email(email, code)
    except Exception as e:
        print(f"메일 발송 실패: {e}")
        raise HTTPException(
            status_code=500,
            detail="메일 발송에 실패했습니다. SMTP 설정을 확인해주세요.",
        )

    if smtp_configured():
        return {"message": "인증번호를 메일로 보냈습니다."}

    return {
        "message": "개발 모드: 서버 콘솔에 인증번호를 출력했습니다.",
        "dev": True,
    }


@app.post("/auth/verify-code")
def verify_code(body: VerifyCodeBody):
    email = normalize_email(body.email)
    ensure_school_email(email)

    code = body.code.strip()
    saved = _codes.get(email)

    if not saved:
        return {"verified": False, "message": "인증번호 요청 기록이 없습니다."}

    current = now_seconds()

    if current > saved["expires_at"]:
        _codes.pop(email, None)
        return {"verified": False, "message": "인증번호가 만료되었습니다."}

    saved["attempts"] += 1

    if saved["attempts"] > 5:
        _codes.pop(email, None)
        return {"verified": False, "message": "시도 횟수를 초과했습니다."}

    if saved["code"] != code:
        return {"verified": False, "message": "인증번호가 올바르지 않습니다."}

    _codes.pop(email, None)

    return {
        "verified": True,
        "message": "학교 이메일 인증이 완료되었습니다.",
    }
