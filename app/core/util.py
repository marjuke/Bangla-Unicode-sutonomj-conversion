import re

def doCharMap(text, charMap):
    for srcKey, keyVal in charMap.items():
        text = preg_replace(srcKey, keyVal, text)
    return text

def mb_strlen(str):
    return len(str)

def mbCharAt(str, i):
    try:
        return str[i]
    except:
        pass

def subString(string, frm, to):
    return string[frm:to]

def preg_replace(srcKey, keyVal, text):
    return re.sub(srcKey, keyVal, text)
