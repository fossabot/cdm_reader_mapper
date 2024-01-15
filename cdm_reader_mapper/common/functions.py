import pandas as pd


def df_prepend_datetime(df, date_columns, date_format, date_name="_datetime"):
    to_convert = df[date_columns].astype(str).apply("-".join, axis=1)
    return pd.concat(
        [
            pd.DataFrame(
                pd.to_datetime(
                    to_convert, format="-".join(date_format), errors="coerce"
                ),
                columns=[date_name],
            ),
            df,
        ],
        sort=False,
        axis=1,
    )
