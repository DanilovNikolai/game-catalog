import { Suspense } from "react";
import { redirect } from "next/navigation";
import { getSession } from "@/lib/session";
import { RegisterForm } from "./register-form";

export default function RegisterPage() {
  return (
    <Suspense fallback={<p className="p-6 text-center">Загрузка...</p>}>
      <RegisterRedirectGuard />
    </Suspense>
  );
}

async function RegisterRedirectGuard() {
  const session = await getSession();

  if (session) {
    redirect("/");
  }

  return <RegisterForm />;
}
