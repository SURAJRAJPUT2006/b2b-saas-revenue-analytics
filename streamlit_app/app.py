import streamlit as st
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler

st.set_page_config(page_title="Velocity SaaS Analytics", layout="wide")
st.title("Velocity SaaS: Revenue Operations & Churn Engine")

# --- BACKEND ML LOGIC ---
# Load data 
df = pd.read_csv('streamlit_app/training_model_churn_data.csv')

# Train model and cache so it does not retrain on every slider click
@st.cache_resource
def train_model(data):
    temp = data.drop('account_id', axis=1)
    encoded = pd.get_dummies(temp, columns=['plan_tier', 'industry', 'referral_source'], drop_first=True)
    X = encoded.drop('churn_flag', axis=1)
    y = encoded['churn_flag']
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    model = LogisticRegression(class_weight='balanced', max_iter=1000, random_state=42)
    model.fit(X_scaled, y)
    return model, scaler, X.columns

model, scaler, feature_cols = train_model(df)

# --- GLOBAL SIDEBAR  ---
st.sidebar.header("Customer Details")
active_days = st.sidebar.slider("Active days last month", 0, 30, 15)
tickets = st.sidebar.slider("Support tickets", 0, 20, 2)
resolution_time = st.sidebar.slider("Avg resolution time (hours)", 1, 120, 24)
csat = st.sidebar.slider("CSAT score", 1.0, 5.0, 4.0, 0.1)
has_sso = st.sidebar.checkbox("Has SSO enabled")
has_webhook = st.sidebar.checkbox("Has webhooks enabled")
plan = st.sidebar.selectbox("Plan tier", ['Basic', 'Pro', 'Enterprise'])
industry = st.sidebar.selectbox("Industry", df['industry'].unique())
source = st.sidebar.selectbox("Referral source", df['referral_source'].unique())

# Build input row and calculate probability throgh sliders
input_row = {
    'total_tickets': tickets,
    'avg_csat': csat,
    'avg_res_time': resolution_time,
    'has_sso': 1 if has_sso else 0,
    'has_webhook': 1 if has_webhook else 0,
    'active_days_last_month': active_days,
    'plan_tier': plan,
    'industry': industry,
    'referral_source': source
}
input_df = pd.DataFrame([input_row])
input_encoded = pd.get_dummies(input_df, columns=['plan_tier', 'industry', 'referral_source'])
input_encoded = input_encoded.reindex(columns=feature_cols, fill_value=0)
input_scaled = scaler.transform(input_encoded)
prob = model.predict_proba(input_scaled)[0][1] * 100

# 2. Tabs for the UI
tab1, tab2 = st.tabs(["📊 Executive Dashboards", "🤖 Real-Time Churn Predictor"])

# --- TAB 1: THE VISUAL PROOF (Assets) ---
with tab1:
    st.header("Historical Revenue Leakage & Insights")
    st.write("Analysis of 2.2M rows of telemetry data revealed critical MRR decay drivers.")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Note the fixed file paths here!
        st.image("streamlit_app/assets/cohort_heatmap.png", caption="The Enterprise Crisis")
        st.image("streamlit_app/assets/support_sla_trap.png", caption="The Support SLA Trap")
        
    with col2:
        st.image("streamlit_app/assets/feature_impact.png", caption="The Golden Handcuffs (SSO/Webhooks)")
        
    st.info("💡 **Business Takeaway:** Enterprise accounts churn at 13.8%. Missing the 48-hour support SLA spikes churn probability to over 18%. Integrating SSO reduces churn by 25%.")

# --- TAB 2: PREDICTIVE ENGINE (The Calculator) ---
with tab2:
    st.header("Predictive Churn Engine (98% Recall)")
    st.write("Adjust customer parameters in the sidebar to calculate real-time churn probability.")
    
    st.subheader("Churn Risk Prediction")

    if prob > 70:
        st.error(f"High risk: {prob:.1f}% chance of churn")
    elif prob > 40:
        st.warning(f"Medium risk: {prob:.1f}% chance of churn")
    else:
        st.success(f"Low risk: {prob:.1f}% chance of churn")

    st.caption("Adjust the sidebar values to see how risk changes")

    # Debugger Expander
    st.markdown("---")
    with st.expander("🔍 Model Debugger (Click to open)"):
        st.write("### 1. Model Feature Weights")
        st.write("If a weight is Positive, it increases churn risk. If Negative, it decreases risk.")
        
        coef_df = pd.DataFrame({
            'Feature': feature_cols,
            'Weight': model.coef_[0]
        }).sort_values(by='Weight', ascending=False)
        st.dataframe(coef_df)

        st.write("### 2. Exact Scaled Input")
        st.write("This is the exact math array passed to the model after scaling:")
        scaled_df = pd.DataFrame(input_scaled, columns=feature_cols)
        st.dataframe(scaled_df)
