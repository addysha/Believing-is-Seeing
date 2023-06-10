from datetime import datetime
from firebase_admin.firestore import GeoPoint

class FirestoreTriggerConverter(object):
    def __init__(self, client=None) -> None:
        self.client = client
        self._action_dict = {
        'geoPointValue': (lambda x: GeoPoint(dict(x)['latitude'], dict(x)['longitude'])),
        'stringValue': (lambda x: str(x)),
        'arrayValue': (lambda x: [self._parse_value(value_dict) for value_dict in x.get("values", [])]),
        'booleanValue': (lambda x: bool(x)),
        'nullValue': (lambda x: None),
        'timestampValue': (lambda x: self._parse_timestamp(x)),
        'referenceValue': (lambda x: self._parse_doc_ref(x)),
        'mapValue': (lambda x: {key: self._parse_value(value) for key, value in x["fields"].items()}),
        'integerValue': (lambda x: int(x)),
        'doubleValue': (lambda x: float(x)),
    }

    def convert(self, data_dict: dict) -> dict:
        result_dict = {}
        for key, value_dict in data_dict.items():
            result_dict[key] = self._parse_value(value_dict)
        return result_dict

    def _parse_value(self, value_dict: dict):
        data_type, value = value_dict.popitem()

        return self._action_dict[data_type](value)

    def _parse_timestamp(self, timestamp: str):
        try:
            return datetime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S.%fZ')
        except ValueError as e:
            return datetime.strptime(timestamp, '%Y-%m-%dT%H:%M:%SZ')

