import { Suspense, type ReactNode } from "react";
import { requireAuth } from "@/lib/require-auth";

export default function ProtectedLayout({ children }: { children: ReactNode }) {
  return (
    <Suspense fallback={<p className="p-6">Проверка авторизации...</p>}>
      <AuthGuard>{children}</AuthGuard>
    </Suspense>
  );
}

async function AuthGuard({ children }: { children: ReactNode }) {
  await requireAuth();

  return children;
}
