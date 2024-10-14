import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import {
  holesky,
  mainnet,
} from 'wagmi/chains';

export const config = getDefaultConfig({
  appName: 'RainbowKit App',
  projectId: 'YOUR_PROJECT_ID',
  chains: [
    mainnet,
    ...(process.env.NEXT_PUBLIC_ENABLE_TESTNETS === 'true' ? [holesky] : []),
  ],
  ssr: true,
});