"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
  }, []);

  return (
    <div className="flex items-center flex-col flex-grow pt-10">
      <div className="px-5">
        <h1 className="text-center mb-8">
          <span className="block text-2xl mb-2">Welcome to</span>
          <span className="block text-4xl font-bold">Scaffold-ETH 2</span>
        </h1>
        <div className="flex justify-center items-center space-x-2">
          <p className="my-2 font-medium">Connected Address:</p>
          <p>{isClient && connectedAddress ? connectedAddress : "Not connected"}</p>
        </div>
        <div className="flex justify-center mt-5">
          <Link href="/example-ui" className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
            Go to Example UI
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Home;
