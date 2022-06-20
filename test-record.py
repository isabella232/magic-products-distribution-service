import json
from copy import deepcopy
from pathlib import Path

from bas_metadata_library.standards.iso_19115_2 import MetadataRecordConfigV3 as MetadataRecordConfig
from bas_metadata_library.standards.iso_19115_common.utils import encode_config_for_json
from jsonschema.validators import validate

record_path = Path('./test-record.json')
schema_path = Path('./schema.json')

if __name__ == "__main__":
    record_config = MetadataRecordConfig()
    record_config.load(file=record_path)
    _config = encode_config_for_json(config=deepcopy(record_config.config))

    with open(schema_path, mode='r') as schema_file:
        schema_data = json.load(schema_file)
    _schema = schema_data

    validate(instance=_config, schema=_schema)

    print('ok')
