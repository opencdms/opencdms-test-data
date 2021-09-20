import os.path

import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

if __name__ == "__main__":
    dataframe = pd.read_csv(
        os.path.join(DATA_DIR, "badc/ukmo-midas-open/data/uk-daily-rain-obs/dataset-version-201908/berkshire/00838_bracknell-beaufort-park/qc-version-1/midas-open_uk-daily-rain-obs_dv-201908_berkshire_00838_bracknell-beaufort-park_qcv-1_1991.csv"),
        header=61
    )
    pd.options.display.max_columns = 20
    print(dataframe.head(1))
