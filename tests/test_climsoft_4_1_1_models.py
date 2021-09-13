from opencdms.models import get_schema_diff
from opencdms.models.climsoft.v4_1_1_core import metadata, TARGET_TABLES


def test_should_return_zero_schema_diff():
    assert len(
        get_schema_diff(
            metadata,
            "mysql://root:password@127.0.0.1:33308/mariadb_climsoft_db_v4",
            include_tables=TARGET_TABLES
        )
    ) == 0
