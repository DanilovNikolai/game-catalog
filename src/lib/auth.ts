import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import { prisma } from "@/lib/prisma";

export const auth = betterAuth({
  database: prismaAdapter(prisma, {
    provider: "postgresql",
  }),

  emailAndPassword: {
    enabled: true,
  },

  user: {
    additionalFields: {
      roleId: {
        type: "string",
        required: false,
        input: false,
      },
    },
  },

  databaseHooks: {
    user: {
      create: {
        before: async (user) => {
          const defaultRole = await prisma.role.findUnique({
            where: {
              slug: "user",
            },
            select: {
              id: true,
            },
          });

          if (!defaultRole) {
            throw new Error("Default role 'user' was not found");
          }

          return {
            data: {
              ...user,
              roleId: defaultRole.id,
            },
          };
        },
      },
    },
  },
});
