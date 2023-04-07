import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import random
from datetime import datetime
from time import sleep

cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

sensors = ["sensorOne"]
for sensor in sensors:
    for day in range(1, 30): 
        for hour in range(0, 24):
            fecha = datetime.strptime(f"2023-04-{day} {hour}:01:00".format(hour=hour), "%Y-%m-%d %H:%M:%S")
            print(day)
            print(fecha)
            sensor_data = {
                "humidity": round(random.uniform(0, 100), 2),
                "temperature": round(random.uniform(10, 40), 2),
                "pressure": round(random.uniform(900, 1100), 2),
                "altitude": round(random.uniform(0, 500), 2),
                "light": round(random.uniform(0, 100), 2),
                "soilMoisture": round(random.uniform(0, 100), 2),
                "rain": round(random.uniform(0, 10), 2),
                "battery": round(random.uniform(0, 100), 2),
                'date': fecha,
                "sensorName": sensor
            }
            db.collection("users/yuY2SQJgcOYgPUKvUdRx/measures").add(sensor_data)

sensors2 = ["sensorOne", "sensorTwo", "sensorThree", "sensorFour"]
for sensor in sensors2:
    fecha = datetime.strptime(f"2022-05-4 00:00:01", "%Y-%m-%d %H:%M:%S")
    print(fecha)
    sensor_data = {
        "humidity": round(random.uniform(0, 100), 2),
        "temperature": round(random.uniform(10, 40), 2),
        "pressure": round(random.uniform(900, 1100), 2),
        "altitude": round(random.uniform(0, 500), 2),
        "light": round(random.uniform(0, 100), 2),
        "soilMoisture": round(random.uniform(0, 100), 2),
        "rain": round(random.uniform(0, 10), 2),
        "battery": round(random.uniform(0, 100), 2),
        u'date': fecha,
        "sensorName": sensor
    }
    print("date"+ str(fecha))
    db.collection("users/yuY2SQJgcOYgPUKvUdRx/lastMeasures").document(sensor).set(sensor_data)

limits = ["humidity", "temperature", "pressure", "altitude", "light", "soilMoisture", "rain", "battery"]
for limit in limits:
    limit_data = {
        "min": round(random.uniform(0, 20), 2),
        "max": round(random.uniform(30, 10), 2),
        "measure": limit
    }
    print("added" + str(limit_data))
    db.collection("users/yuY2SQJgcOYgPUKvUdRx/userLimits").document(limit).set(limit_data)