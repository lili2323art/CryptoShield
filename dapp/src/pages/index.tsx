import { ConnectButton } from "@rainbow-me/rainbowkit";
import type { NextPage } from "next";
import Head from "next/head";
import styles from "../styles/Home.module.css";
import nftabis from "../abis/nft.json";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@/components/ui/carousel";
import Image from "next/image";
import { useEffect, useRef, useState } from "react";
import {
  useWriteContract,
  useReadContract,
  useWaitForTransactionReceipt,
} from "wagmi";
import { useToast } from "@/hooks/use-toast";
import SliderCaptcha, { ActionType } from "rc-slider-captcha";
import {
  ArrowRepeat,
  EmojiFrownFill,
  EmojiSmileFill,
  Gem,
  Heart,
} from "doly-icons";
import { getCaptcha, verifyCaptcha } from "@/services/captchaService";
import { useAccount } from "wagmi";
import { encodeAbiParameters, keccak256, parseAbiParameters, recoverMessageAddress, toBytes } from "viem";

// 假设这是您的 NFT 合约 ABI 和地址
const NFT_CONTRACT_ABI = nftabis;
const NFT_CONTRACT_ADDRESS = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS;

const MintNFT: React.FC = () => {
  const { toast } = useToast();
  const [isCaptchaVerified, setIsCaptchaVerified] = useState(false);
  const captchaActionRef = useRef<ActionType>();
  const { address } = useAccount();
  const [signature, setSignature] = useState<string | null>(null);

  const {
    data: hash,
    error: writeError,
    isPending,
    writeContractAsync,
  } = useWriteContract();

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  const { data: currentTokenId } = useReadContract({
    abi: NFT_CONTRACT_ABI,
    address: NFT_CONTRACT_ADDRESS as `0x${string}`,
    functionName: "totalSupply",
  });

  const getSignature = async () => {
    if (!address || currentTokenId === undefined) return;

    const response = await fetch("/api/sign-mint", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ address, tokenId: Number(currentTokenId) + 1 }),
    });

    const data = await response.json();
    setSignature(data.signature);
  };

  const handleMint = async () => {
    if (!signature) {
      await getSignature();
    }

    // 编码消息
    const message = encodeAbiParameters(
      parseAbiParameters('address, uint256'),
      [address as `0x${string}`, BigInt(Number(currentTokenId) + 1)]
    );

    // 计算消息哈希
    const messageHash = keccak256(message);

    // 计算以太坊签名消息哈希
    const ethSignedMessageHash = keccak256(
      toBytes(`\x19Ethereum Signed Message:\n32${messageHash.slice(2)}`)
    );

    const recoveredAddress = await recoverMessageAddress({
      message: { raw: messageHash },
      signature: signature as `0x${string}`,
    });

    console.log('Recovered address:', recoveredAddress);
    console.log('Original message:', message);
    console.log('Message hash:', messageHash);
    console.log('Eth Signed Message Hash:', ethSignedMessageHash);
    console.log('Signature:', signature);

    await writeContractAsync({
      abi: NFT_CONTRACT_ABI,
      address: NFT_CONTRACT_ADDRESS as `0x${string}`,
      functionName: "mintNFT",
      args: [signature],
    });
  };

  useEffect(() => {
    if (isConfirmed) {
      toast({
        title: "Success",
        description: "NFT minted successfully!",
      });
      setIsCaptchaVerified(false);
      captchaActionRef.current?.refresh();
    }
  }, [isConfirmed, toast]);

  useEffect(() => {
    if (writeError) {
      toast({
        variant: "destructive",
        title: "Error",
        description:
          (writeError as Error)?.message || "An error occurred while minting",
      });
    }
  }, [writeError, toast]);

  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle>Mint Your NFT</CardTitle>
        <CardDescription>Get your unique NFT now!</CardDescription>
      </CardHeader>
      <CardContent>
        <Carousel>
          <CarouselContent>
            {[1, 2, 3].map((id) => (
              <CarouselItem key={id}>
                <Image
                  src={`/nft/${id}.png`}
                  alt={`NFT Preview ${id}`}
                  width={300}
                  height={300}
                />
              </CarouselItem>
            ))}
          </CarouselContent>
          <CarouselPrevious />
          <CarouselNext />
        </Carousel>
        <SliderCaptcha
          mode="float"
          request={getCaptcha}
          onVerify={(data) => {
            return verifyCaptcha(data).then(() => {
              setIsCaptchaVerified(true);
              toast({
                title: "Captcha Verified",
                description: "You can now mint your NFT.",
              });
            });
          }}
          actionRef={captchaActionRef}
          tipIcon={{
            default: <Gem />,
            loading: <ArrowRepeat />,
            success: <EmojiSmileFill />,
            error: <EmojiFrownFill />,
            refresh: <ArrowRepeat />,
          }}
          tipText={{
            default: "Slide to verify",
            loading: "Loading...",
            moving: "Slide to the correct position",
            verifying: "Verifying...",
            error: "Verification failed",
          }}
          style={{
            "--rcsc-primary": "#e91e63",
            "--rcsc-primary-light": "#f8bbd0",
            "--rcsc-panel-border-radius": "10px",
            "--rcsc-control-border-radius": "20px",
            width: "300px",
            marginTop: "20px",
          }}
        />
      </CardContent>
      <CardFooter>
        <Button
          onClick={handleMint}
          disabled={isPending || isConfirming || !isCaptchaVerified || !address}
        >
          {isPending
            ? "Confirming..."
            : isConfirming
            ? "Minting..."
            : "Mint NFT"}
        </Button>
      </CardFooter>
    </Card>
  );
};

const Home: NextPage = () => {
  return (
    <div className={styles.container}>
      <Head>
        <title>Mint NFT by CryptoShield</title>
        <meta
          content="Generated by @rainbow-me/create-rainbowkit"
          name="description"
        />
        <link href="/favicon.ico" rel="icon" />
      </Head>

      <header className={styles.header}>
        <div className={styles.logoTitle}>
          <h1 className={styles.title}>NFT Mint</h1>
        </div>
        <ConnectButton />
      </header>

      <main className={styles.main}>
        <MintNFT />
      </main>

      <footer className={styles.footer}>Made by CryptoShield 🥳</footer>
    </div>
  );
};

export default Home;
