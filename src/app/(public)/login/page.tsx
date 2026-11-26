import { Suspense } from "react";
import { redirect } from "next/navigation";
import { getSession } from "@/lib/session";
import { LoginForm } from "./login-form";

export default function LoginPage() {
  return (
    <Suspense fallback={<p className="p-6 text-center">Загрузка...</p>}>
      <LoginRedirectGuard />
    </Suspense>
  );
}

async function LoginRedirectGuard() {
  const session = await getSession();

  if (session) {
    redirect("/");
  }

  return <LoginForm />;
}
