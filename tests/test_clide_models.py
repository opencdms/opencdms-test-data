from opencdms.models import get_schema_diff
from opencdms.models.clide import metadata, CLIDE_VIEWS


def test_should_return_zero_schema_diff():
    assert len(
        get_schema_diff(
            metadata,
            "postgresql+psycopg2://postgres:password@localhost:35432",
            exclude_tables=CLIDE_VIEWS
        )
    ) == 0
