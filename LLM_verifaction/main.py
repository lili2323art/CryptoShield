import pandas as pd
import requests

# 读取CSV文件
df = pd.read_csv('transaction_dataset_test.csv')

# 定义API的URL和API密钥
api_url = 'https://api.dify.ai/v1/chat-messages'
api_key = 'app-w3Lo8Lx1jKJ1GbJau5d42Spf'  # 替换为您的API密钥

# 遍历每一行数据
for index, row in df.iterrows():
    # 构建输入字符串
    input_data = f"{row['Index']} {row['Address']} {row['Avg_min_between_sent_tnx']} {row['Avg_min_between_received_tnx']} {row['Time_Diff_between_first_and_last_Mins']} {row['Sent_tnx']} {row['Received_Tnx']} {row['Number_of_Created_Contracts']} {row['Unique_Received_From_Addresses']} {row['Unique_Sent_To_Addresses']} {row['min_value_received']} {row['max_value_received']} {row['avg_val_received']} {row['min_value_sent']} {row['max_value_sent']} {row['avg_val_sent']} {row['min_value_sent_to_contract']} {row['max_value_sent_to_contract']} {row['avg_value_sent_to_contract']} {row['total_transactions']} {row['total_Ether_sent']} {row['total_ether_received']} {row['total_ether_sent_contracts']} {row['total_ether_balance']} {row['Total_ERC20_tnxs']} {row['ERC20_total_Ether_received']} {row['ERC20_total_ether_sent']} {row['ERC20_total_Ether_sent_contract']} {row['ERC20_uniq_sent_addr']} {row['ERC20_uniq_rec_addr']} {row['ERC20_uniq_sent_addr_1']} {row['ERC20_uniq_rec_contract_addr']} {row['ERC20_avg_time_between_sent_tnx']} {row['ERC20_avg_time_between_rec_tnx']} {row['ERC20_avg_time_between_rec_2_tnx']} {row['ERC20_avg_time_between_contract_tnx']} {row['ERC20_min_val_rec']} {row['ERC20_max_val_rec']} {row['ERC20_avg_val_rec']} {row['ERC20_min_val_sent']} {row['ERC20_max_val_sent']} {row['ERC20_avg_val_sent']} {row['ERC20_min_val_sent_contract']} {row['ERC20_max_val_sent_contract']} {row['ERC20_avg_val_sent_contract']} {row['ERC20_uniq_sent_token_name']} {row['ERC20_uniq_rec_token_name']} {row['ERC20_most_sent_token_type']} {row['ERC20_most_rec_token_type']}"

    # 构建请求数据
    data = {
        "inputs": {
            "index": str(row['Index']),  # Convert index to string
            "address": row['Address'],
            # 其他字段...
        },
        "query": input_data,
        "response_mode": "blocking",  # Change to blocking
        "conversation_id": "",
        "user": "abc-123",
        "files": []
    }
    
    # 调用API
    response = requests.post(api_url, headers={
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json'
    }, json=data)
    
    # 检查响应状态
    if response.status_code == 200:
        try:
            result = response.json().get('answer')  # 获取API返回的'answer'字段
            if result == "true":
                print(0)
            elif result == "false":
                print(1)
        except requests.exceptions.JSONDecodeError:
            print("Response is not valid JSON. Response text:", response.text)
            result = None
    else:
        print(f"Error: {response.status_code} - {response.text}")
