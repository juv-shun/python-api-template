from datetime import datetime, timedelta, timezone

from pythonjsonlogger import jsonlogger

JST = timezone(timedelta(hours=+9), "JST")


class JsonFormatter(jsonlogger.JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super().add_fields(log_record, record, message_dict)
        if not log_record.get('timestamp'):
            log_record['timestamp'] = datetime.now(JST).replace(microsecond=0).isoformat()
        if log_record.get('level'):
            log_record['level'] = log_record['level'].upper()
        else:
            log_record['level'] = record.levelname
