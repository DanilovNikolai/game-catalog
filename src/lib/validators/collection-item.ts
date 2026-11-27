import { z } from "zod";

type MoneyPairStatus = "valid" | "missingAmount" | "missingCurrency";
type Amount = number | null | undefined;
type Currency = string | null | undefined;

function getMoneyPairStatus(
  amount: Amount,
  currency: Currency,
): MoneyPairStatus {
  if (amount != null && currency == null) {
    return "missingCurrency";
  }

  if (amount == null && currency != null) {
    return "missingAmount";
  }

  return "valid";
}

function addMoneyPairIssues(
  status: MoneyPairStatus,
  amountField: string,
  currencyField: string,
  amountMessage: string,
  currencyMessage: string,
  ctx: z.RefinementCtx,
) {
  if (status === "missingCurrency") {
    ctx.addIssue({
      code: "custom",
      path: [currencyField],
      message: currencyMessage,
    });
  }

  if (status === "missingAmount") {
    ctx.addIssue({
      code: "custom",
      path: [amountField],
      message: amountMessage,
    });
  }
}

export const collectionItemSchema = z
  .object({
    conditionGrade: z
      .number()
      .int("Оценка состояния должна быть целым числом")
      .min(1, "Минимальная оценка состояния — 1")
      .max(10, "Максимальная оценка состояния — 10"),

    completeness: z.enum(["cib", "loose", "sealed"]),

    personalRating: z
      .number()
      .int("Рейтинг должен быть целым числом")
      .min(1, "Минимальный рейтинг — 1")
      .max(10, "Максимальный рейтинг — 10")
      .nullable()
      .optional(),

    playStatus: z
      .enum(["not_started", "in_progress", "completed"])
      .default("not_started"),

    purchasePrice: z.number().nonnegative().nullable().optional(),

    purchaseCurrency: z
      .string()
      .length(3, "Код валюты должен состоять из 3 символов")
      .nullable()
      .optional(),

    estimatedMarketValue: z.number().nonnegative().nullable().optional(),

    estimatedMarketCurrency: z
      .string()
      .length(3, "Код валюты должен состоять из 3 символов")
      .nullable()
      .optional(),

    collectionEditionTypeId: z.string().uuid().nullable().optional(),
    notes: z.string().nullable().optional(),

    acquiredAt: z
      .string()
      .regex(/^\d{2}\.\d{2}\.\d{4}$/, "Дата должна быть в формате ДД.ММ.ГГГГ")
      .refine((value) => {
        const [day, month, year] = value.split(".").map(Number);

        const date = new Date(Date.UTC(year, month - 1, day));

        return (
          date.getUTCDate() === day &&
          date.getUTCMonth() === month - 1 &&
          date.getUTCFullYear() === year
        );
      }, "Указана некорректная дата")
      .nullable()
      .optional(),
  })
  .superRefine((data, ctx) => {
    const purchaseStatus = getMoneyPairStatus(
      data.purchasePrice,
      data.purchaseCurrency,
    );

    addMoneyPairIssues(
      purchaseStatus,
      "purchasePrice",
      "purchaseCurrency",
      "Необходимо указать цену покупки",
      "Необходимо указать валюту покупки",
      ctx,
    );

    const marketValueStatus = getMoneyPairStatus(
      data.estimatedMarketValue,
      data.estimatedMarketCurrency,
    );

    addMoneyPairIssues(
      marketValueStatus,
      "estimatedMarketValue",
      "estimatedMarketCurrency",
      "Необходимо указать рыночную стоимость",
      "Необходимо указать валюту рыночной стоимости",
      ctx,
    );
  });
