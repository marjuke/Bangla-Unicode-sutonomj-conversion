from fastapi import FastAPI
from pydantic import BaseModel

from app.core import converter
from app.core.bijoy_to_unicode import BijoyToUnicode


class TextRequest(BaseModel):
    text: str


class TextResponse(BaseModel):
    text: str


app = FastAPI(title="Unicode/Bijoy Converter API")


@app.get("/health", response_model=TextResponse)
def health():
    return TextResponse(text="ok")



@app.post("/unicode-to-bijoy", response_model=TextResponse)
def unicode_to_bijoy(payload: TextRequest):
    result = converter.Unicode().convertUnicodeToBijoy(payload.text)
    return TextResponse(text=result)


@app.post("/bijoy-to-unicode", response_model=TextResponse)
def bijoy_to_unicode(payload: TextRequest):
    result = BijoyToUnicode().convertBijoyToUnicode(payload.text)
    return TextResponse(text=result)



