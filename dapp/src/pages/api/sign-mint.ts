import { keccak256, encodeAbiParameters, parseAbiParameters, toBytes, SignableMessage } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';

const SIGNER_PRIVATE_KEY = process.env.SIGNER_PRIVATE_KEY as `0x${string}`;

export default async function handler(
  req: { body: { address: string; tokenId: string } },
  res: {
    status: (code: number) => {
      json: (data: { signature: `0x${string}` }) => void;
    };
  }
) {
  const { address, tokenId } = req.body;

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

  console.log('Original message:', message);
  console.log('Message hash:', messageHash);
  console.log('Signature:', signature);

  res.status(200).json({ signature });
}
