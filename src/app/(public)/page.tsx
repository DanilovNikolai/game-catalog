import { Suspense } from "react";
import { getSession } from "@/lib/session";
import { LogoutButton } from "@/components/auth/logout-button";

export default function MainPage() {
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <div className="text-center">
        <h1 className="text-3xl font-bold">Game Catalog</h1>

        <Suspense fallback={<p className="mt-4 text-gray-500">Загрузка...</p>}>
          <UserGreeting />
        </Suspense>
      </div>
    </main>
  );
}

async function UserGreeting() {
  const session = await getSession();

  return session ? (
    <>
      <p className="mt-4 text-gray-600">Вы вошли как {session.user.email}</p>
      <LogoutButton />
    </>
  ) : (
    <p className="mt-4 text-gray-600">Вы не авторизованы</p>
  );
}
