import os
import json
import pysondb
from pysondb.db import JsonDatabase

def getDbDir()->str:
    p = os.environ.get("DB_PATH", "./db")
    if not os.path.exists(p):
        os.makedirs(p)
    return p

def getDbInstance()->JsonDatabase:
    DB_PATH = getDbDir()
    path = os.path.join(DB_PATH, "db.json")
    return pysondb.db.getDb(path)

def getInputDir()->str:
    p = os.environ.get("INPUT_PATH", "./cache/input")
    if not os.path.exists(p):
        os.makedirs(p)
    return os.path.abspath(p)

def getOutputDir()->str:
    p = os.environ.get("OUTPUT_PATH", "./cache/output")
    if not os.path.exists(p):
        os.makedirs(p)
    return os.path.abspath(p)

def getModelPath()->str:
    p = os.environ.get("MODEL_PATH", "./cache/model")
    if not os.path.exists(p):
        os.makedirs(p)
    return os.path.abspath(p)

def getBackgroundIdleSeconds()->int:
    s = os.environ.get("BG_TASK_WAIT_SECS", "5")
    return int(s)

def getTranscribeDevice()->str:
    return os.environ.get("TRANSCRIBE_DEVICE", "auto")

def getServerPort()->int:
    return int(os.environ.get("PORT", "8820"))

def getKikoeruUrl()->str:
    url = os.environ.get("KIKOERU_URL", None)
    if url is None:
        raise Exception("kikoeur url not configed")
    return url.rstrip("/") # remove trailing /

def getKikoeruUser()->str:
    return os.environ.get("KIKOERU_USER", "")

def getKikoeruPassword()->str:
    return os.environ.get("KIKOERU_PASSWORD", "")

def getToken()->str:
    p = getDbDir()
    token_file = os.path.join(p, "token")
    if not os.path.exists(token_file):
        return ""
    with open(token_file, "r", encoding="utf8") as f:
        return f.readline().strip()
    
def saveToken(token:str):
    p = getDbDir()
    token_file = os.path.join(p, "token")
    with open(token_file, "w", encoding="utf8") as f:
        f.write(token)

def getWorkerName()->str:
    return os.environ.get("WORKER_NAME", "default_worker")

# 调用model.transcribe传入的可选参数
def getTrancribeParams()->object:
    # # phanton version
    # default = {
    #     'task': 'transcribe',
    #     'language': 'zh'
    # }

    # 3500 version
    default = {
        'task': 'translate',
        'language': 'ja',
        'vad_filter': True,
        'condition_on_previous_text': True,
    }
    
    # 5000 version (https://huggingface.co/chickenrice0721/whisper-large-v2-translate-zh-v0.2-st-ct2)
    # credit: https://www.south-plus.net/read.php?tid-2690727-fpage-0-toread--page-1.html 
    # default = {
    #     'task': 'translate',
    #     'language': 'ja',
    #     'vad_filter': True,
    #     'vad_parameters': {
    #         # VAD检测阈值
    #         # 太大会导致漏翻, 太小可能会导致时间轴不准或文本质量下降(幻听)
    #         "threshold": 0.5,
    #     },
    #     'condition_on_previous_text': True,
    #     # 避免时间轴向前偏移过长的问题
    #     "max_initial_timestamp": 30,
    #     "repetition_penalty": 1.1,
    # }

    params = default
    try:
        s = os.environ.get("TRANSCRIBE_PARAMS", "")
        if s != "":
            params = json.loads(s)
    except:
        print("get transcribe params failed, fallback to ", default)
        params = default
    return params

db_dir = ""
def getTaskFilePath()->str:
    global db_dir
    if db_dir == "":
        db_dir = getDbDir()
    return os.path.join(db_dir, "task.json")
    