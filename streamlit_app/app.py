from pathlib import Path

import joblib
import numpy as np
import pandas as pd
import streamlit as st


st.set_page_config(
    page_title="Velocity SaaS Churn Risk",
    page_icon="📉",
    layout="wide",
)

MODEL_PATH = Path(__file__).parent / "calibrated_churn_model.joblib"


@st.cache_resource
def load_model_bundle():
    return joblib.load(MODEL_PATH)


def normalise_binary_column(series: pd.Series) -> pd.Series:
    """Convert common True/False, Yes/No, and 0/1 values into 0/1."""
    if pd.api.types.is_bool_dtype(series):
        return series.astype(int)

    text = series.astype(str).str.strip().str.lower()
    mapped = text.map(
        {
            "true": 1,
            "yes": 1,
            "y": 1,
            "1": 1,
            "false": 0,
            "no": 0,
            "n": 0,
            "0": 0,
        }
    )

    numeric = pd.to_numeric(series, errors="coerce")
    return mapped.fillna(numeric)


def prepare_batch_data(data: pd.DataFrame, feature_cols: list[str]):
    """Prepare a client CSV without changing the model's expected columns."""
    prepared = data.copy()

    for column in [
        "account_age_days",
        "total_tickets_90d",
        "avg_csat_90d",
        "avg_res_time_90d",
        "csat_responses_90d",
        "active_days_last_30d",
        "usage_events_last_30d",
    ]:
        if column in prepared.columns:
            prepared[column] = pd.to_numeric(
                prepared[column],
                errors="coerce",
            )

    for column in ["has_sso", "has_webhook"]:
        if column in prepared.columns:
            prepared[column] = normalise_binary_column(
                prepared[column]
            )

    missing = [
        column for column in feature_cols
        if column not in prepared.columns
    ]

    return prepared, missing


st.title("Velocity SaaS — Churn Risk Prioritisation")
st.caption(
    "Calibrated next-60-day risk estimates from a synthetic SaaS model. "
    "Use the score to prioritise review, not as a certainty."
)

if not MODEL_PATH.exists():
    st.error(
        "Model bundle not found. Place calibrated_churn_model.joblib "
        "in the same folder as app.py."
    )
    st.stop()

try:
    bundle = load_model_bundle()
    model = bundle["model"]
    feature_cols = bundle["feature_cols"]
except Exception as exc:
    st.error(f"Could not load the model bundle: {exc}")
    st.stop()

with st.sidebar:
    st.header("About this tool")
    st.write(
        "This app scores account snapshots using recent support, "
        "usage, account, plan, industry, and acquisition signals."
    )
    st.info(
        "The model was validated on a future synthetic test period. "
        "It prioritises accounts for Customer Success review; it does "
        "not prove that an account will churn."
    )

single_tab, batch_tab, model_tab = st.tabs(
    [
        "Single account",
        "Batch CSV queue",
        "Model details",
    ]
)

with single_tab:
    st.subheader("Score one account")

    col1, col2, col3 = st.columns(3)

    with col1:
        account_age_days = st.number_input(
            "Account age (days)",
            min_value=0,
            max_value=5000,
            value=730,
            step=1,
        )
        plan_tier = st.selectbox(
            "Plan tier",
            ["Basic", "Pro", "Enterprise"],
        )
        industry = st.selectbox(
            "Industry",
            [
                "SaaS",
                "E-commerce",
                "Finance",
                "Healthcare",
                "Education",
                "Marketing",
                "Real Estate",
                "Manufacturing",
                "Consulting",
                "Media",
            ],
        )
        referral_source = st.selectbox(
            "Referral source",
            [
                "Organic Search",
                "Paid Search",
                "LinkedIn",
                "Content Marketing",
                "Partnership",
                "Referral",
                "Direct",
                "Events",
            ],
        )

    with col2:
        total_tickets_90d = st.number_input(
            "Support tickets — previous 90 days",
            min_value=0,
            max_value=500,
            value=3,
            step=1,
        )
        avg_csat_90d = st.number_input(
            "Average CSAT — previous 90 days",
            min_value=1.0,
            max_value=5.0,
            value=3.0,
            step=0.1,
        )
        avg_res_time_90d = st.number_input(
            "Average resolution time (hours)",
            min_value=0.0,
            max_value=1000.0,
            value=60.0,
            step=1.0,
        )
        csat_responses_90d = st.number_input(
            "CSAT responses — previous 90 days",
            min_value=0,
            max_value=500,
            value=2,
            step=1,
        )

    with col3:
        active_days_last_30d = st.number_input(
            "Active days — previous 30 days",
            min_value=0,
            max_value=30,
            value=5,
            step=1,
        )
        usage_events_last_30d = st.number_input(
            "Usage events — previous 30 days",
            min_value=0,
            max_value=10000,
            value=35,
            step=1,
        )
        has_sso = st.checkbox("SSO used in first 30 days")
        has_webhook = st.checkbox("Webhook used in first 30 days")

    account_row = pd.DataFrame(
        [
            {
                "account_age_days": account_age_days,
                "plan_tier": plan_tier,
                "industry": industry,
                "referral_source": referral_source,
                "total_tickets_90d": total_tickets_90d,
                "avg_csat_90d": avg_csat_90d,
                "avg_res_time_90d": avg_res_time_90d,
                "csat_responses_90d": csat_responses_90d,
                "active_days_last_30d": active_days_last_30d,
                "usage_events_last_30d": usage_events_last_30d,
                "has_sso": int(has_sso),
                "has_webhook": int(has_webhook),
            }
        ]
    )

    if st.button("Calculate risk", type="primary"):
        probability = model.predict_proba(
            account_row[feature_cols]
        )[0, 1]

        st.metric(
            "Estimated next-60-day churn risk",
            f"{probability:.2%}",
        )

        st.info(
            "Use this score to prioritise review against the rest of "
            "the account base. The application does not apply a fixed "
            "High/Medium/Low threshold because that threshold depends "
            "on the Customer Success team's review capacity."
        )

        st.caption(
            "This is a calibrated model estimate from synthetic data, "
            "not a guarantee or causal explanation."
        )

with batch_tab:
    st.subheader("Create a Customer Success priority queue")
    st.write(
        "Upload one row per account using the same feature columns used "
        "during model training."
    )

    uploaded_file = st.file_uploader(
        "Upload account feature CSV",
        type=["csv"],
    )

    if uploaded_file is not None:
        try:
            raw_batch = pd.read_csv(uploaded_file)
            batch, missing_columns = prepare_batch_data(
                raw_batch,
                feature_cols,
            )

            if missing_columns:
                st.error(
                    "Missing required columns: "
                    + ", ".join(missing_columns)
                )
            else:
                scores = model.predict_proba(
                    batch[feature_cols]
                )[:, 1]

                result = batch.copy()
                result["estimated_churn_risk"] = scores
                result["estimated_churn_risk_pct"] = (
                    result["estimated_churn_risk"] * 100
                ).round(2)
                result["priority_rank"] = (
                    result["estimated_churn_risk"]
                    .rank(method="first", ascending=False)
                    .astype(int)
                )

                result = result.sort_values(
                    "estimated_churn_risk",
                    ascending=False,
                )

                st.success(
                    f"Scored {len(result):,} account rows."
                )

                display_columns = [
                    column for column in [
                        "account_id",
                        "plan_tier",
                        "industry",
                        "estimated_churn_risk_pct",
                        "priority_rank",
                        "active_days_last_30d",
                        "usage_events_last_30d",
                        "avg_csat_90d",
                        "total_tickets_90d",
                    ]
                    if column in result.columns
                ]

                st.dataframe(
                    result[display_columns],
                    use_container_width=True,
                    hide_index=True,
                )

                csv_data = result.to_csv(index=False).encode("utf-8")

                st.download_button(
                    "Download scored priority queue",
                    data=csv_data,
                    file_name="scored_churn_priority_queue.csv",
                    mime="text/csv",
                )

        except Exception as exc:
            st.error(f"Could not score the CSV: {exc}")

with model_tab:
    st.subheader("Model information")

    st.write("**Target:**", bundle.get("target"))
    st.write(
        "**Prediction horizon:**",
        bundle.get("prediction_horizon"),
    )

    st.write("**Features used:**")
    st.code("\n".join(feature_cols))

    st.warning(
        "The model is a prioritisation aid. It does not establish "
        "causation and it does not guarantee churn."
    )
