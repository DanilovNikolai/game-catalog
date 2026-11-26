"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { authClient } from "@/lib/auth-client";

export function LogoutButton() {
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  async function handleLogout() {
    setIsLoading(true);

    try {
      await authClient.signOut();
      router.push("/login");
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <button
      type="button"
      onClick={handleLogout}
      disabled={isLoading}
      className="mt-6 rounded-md bg-red-600 px-4 py-2 text-white hover:bg-red-700 disabled:opacity-50"
    >
      {isLoading ? "Выходим..." : "Выйти"}
    </button>
  );
}
