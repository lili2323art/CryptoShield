import { keccak256, encodeAbiParameters, parseAbiParameters, toBytes, SignableMessage } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import axios from 'axios';

const SIGNER_PRIVATE_KEY = process.env.SIGNER_PRIVATE_KEY as `0x${string}`;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const NFT_CONTRACT_ADDRESS = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS;
const DIFY_API_KEY = process.env.DIFY_API_KEY;
const DIFY_API_URL = process.env.DIFY_API_URL || 'https://api.dify.ai/v1/chat-messages';

async function getRecentTransactions(address: string): Promise<any[]> {
  try {
    const response = await axios.get(`https://api.etherscan.io/api`, {
      params: {
        module: 'account',
        action: 'txlist',
        address: address,
        startblock: 0,
        endblock: 99999999,
        page: 1,
        offset: 5,
        sort: 'desc',
        apikey: ETHERSCAN_API_KEY
      }
    });

    if (response.data.status === '1') {
      return response.data.result;
    } else {
      throw new Error('Failed to fetch recent transactions');
    }
  } catch (error) {
    console.error('Error fetching recent transactions:', error);
    throw error;
  }
}

async function checkAddressWithLLM(transactions: any[]): Promise<boolean> {
  try {
    const inputData = transactions.map(tx => `${tx.from} ${tx.to} ${tx.value} ${tx.input}`).join(' ');

    const response = await axios.post(DIFY_API_URL, {
      inputs: { transactions: inputData },
      query: inputData,
      response_mode: "blocking",
      conversation_id: "",
      user: "abc-123"
    }, {
      headers: {
        'Authorization': `Bearer ${DIFY_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    if (response.status === 200) {
      const result = response.data.answer;
      return result.toLowerCase() === 'true';
    } else {
      throw new Error('Failed to get LLM response');
    }
  } catch (error) {
    console.error('Error checking address with LLM:', error);
    throw error;
  }
}

async function getNFTBalance(address: string): Promise<number> {
  try {
    const response = await axios.get(`https://api-holesky.etherscan.io/api`, {
      params: {
        module: 'account',
        action: 'tokenbalance',
        contractaddress: NFT_CONTRACT_ADDRESS,
        address: address,
        tag: 'latest',
        apikey: ETHERSCAN_API_KEY
      }
    });

    if (response.data.status === '1') {
      return parseInt(response.data.result);
    } else {
      throw new Error('Failed to fetch NFT balance');
    }
  } catch (error) {
    console.error('Error fetching NFT balance:', error);
    throw error;
  }
}

export default async function handler(
  req: { body: { address: string; tokenId: string; captchaVerified: boolean } },
  res: {
    status: (code: number) => {
      json: (data: { signature?: `0x${string}`; error?: string }) => void;
    };
  }
) {
  const { address, tokenId, captchaVerified } = req.body;

  if (!captchaVerified) {
    return res.status(400).json({ error: 'Captcha verification failed' });
  }

  try {
    // 获取最近的交易
    const recentTransactions = await getRecentTransactions(address);

    // 使用大模型检查地址
    const isBlacklisted = await checkAddressWithLLM(recentTransactions);

    if (isBlacklisted) {
      return res.status(403).json({ error: 'This address was blacklisted by the AI agent' });
    }

    const nftBalance = await getNFTBalance(address);
    if (nftBalance >= 2) {
      return res.status(403).json({ error: 'You already own 2 or more NFTs' });
    }

    // 编码消息
    const message = encodeAbiParameters(
      parseAbiParameters('address, uint256'),
      [address as `0x${string}`, BigInt(tokenId)]
    );

    // 计算消息哈希
    const messageHash = keccak256(message);

    // 确保私钥是正确的格式
    if (!SIGNER_PRIVATE_KEY || !SIGNER_PRIVATE_KEY.startsWith('0x') || SIGNER_PRIVATE_KEY.length !== 66) {
      throw new Error('Invalid SIGNER_PRIVATE_KEY format');
    }

    console.log('SIGNER_PRIVATE_KEY length:', SIGNER_PRIVATE_KEY?.length);
    const account = privateKeyToAccount(SIGNER_PRIVATE_KEY);

    // 签名原始消息哈希
    const signature = await account.signMessage({ message: { raw: messageHash } as SignableMessage });

    res.status(200).json({ signature });
  } catch (error) {
    console.error('Error in sign-mint:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}
