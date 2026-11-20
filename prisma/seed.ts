import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const platforms = [
  { name: "Sony PlayStation 3", slug: "sony-playstation-3" },
  { name: "Sony PlayStation 4", slug: "sony-playstation-4" },
  { name: "Sony PlayStation 5", slug: "sony-playstation-5" },
  { name: "Nintendo Switch", slug: "nintendo-switch" },
  { name: "Nintendo Switch 2", slug: "nintendo-switch-2" },
  { name: "Microsoft Xbox 360", slug: "microsoft-xbox-360" },
  { name: "Microsoft Xbox One", slug: "microsoft-xbox-one" },
  { name: "Microsoft Xbox Series X", slug: "microsoft-xbox-series-x" },
];

const regions = [
  { name: "North America", slug: "north-america" },
  { name: "Europe", slug: "europe" },
  { name: "Germany", slug: "germany" },
  { name: "Russia", slug: "russia" },
  { name: "United Kingdom", slug: "united-kingdom" },
  { name: "South Korea", slug: "south-korea" },
  { name: "Japan", slug: "japan" },
  { name: "Asia", slug: "asia" },
  { name: "United Arab Emirates", slug: "united-arab-emirates" },
  { name: "Australia", slug: "australia" },
  { name: "Brazil", slug: "brazil" },
  { name: "Worldwide", slug: "worldwide" },
  { name: "Unknown", slug: "unknown" },
];

const ratingSystems = [
  { name: "ESRB", slug: "esrb" },
  { name: "PEGI", slug: "pegi" },
  { name: "USK", slug: "usk" },
  { name: "CERO", slug: "cero" },
  { name: "GRAC", slug: "grac" },
  { name: "ACB", slug: "acb" },
  { name: "ClassInd", slug: "classind" },
  { name: "NMA", slug: "nma" },
  { name: "RARS", slug: "rars" },
  { name: "BBFC", slug: "bbfc" },
  { name: "Unknown", slug: "unknown" },
];

const languages = [
  { code: "en", name: "English" },
  { code: "de", name: "German" },
  { code: "ru", name: "Russian" },
  { code: "pt-BR", name: "Portuguese (Brazil)" },
  { code: "pt-PT", name: "Portuguese (Portugal)" },
  { code: "zh-Hans", name: "Chinese (Simplified)" },
  { code: "zh-Hant", name: "Chinese (Traditional)" },
  { code: "es-ES", name: "Spanish (Spain)" },
  { code: "es-419", name: "Spanish (Latin America)" },
];

// Region -> allowed rating systems
const regionRatingMappings = [
  { region: "north-america", ratings: ["esrb"] },
  { region: "europe", ratings: ["pegi"] },
  { region: "germany", ratings: ["usk"] },
  { region: "russia", ratings: ["rars", "pegi"] },
  { region: "united-kingdom", ratings: ["pegi", "bbfc"] },
  { region: "south-korea", ratings: ["grac"] },
  { region: "japan", ratings: ["cero"] },
  { region: "asia", ratings: ["unknown"] },
  { region: "united-arab-emirates", ratings: ["nma"] },
  { region: "australia", ratings: ["acb"] },
  { region: "brazil", ratings: ["classind"] },
  { region: "worldwide", ratings: ["unknown"] },
  { region: "unknown", ratings: ["unknown"] },
];

async function main() {
  // Platforms
  for (const platform of platforms) {
    await prisma.platform.upsert({
      where: { slug: platform.slug },
      update: { name: platform.name, isActive: true },
      create: platform,
    });
  }

  // Regions
  for (const region of regions) {
    await prisma.region.upsert({
      where: { slug: region.slug },
      update: { name: region.name, isActive: true },
      create: region,
    });
  }

  // Rating systems
  for (const rating of ratingSystems) {
    await prisma.ratingSystem.upsert({
      where: { slug: rating.slug },
      update: { name: rating.name, isActive: true },
      create: rating,
    });
  }

  // Languages
  for (const language of languages) {
    await prisma.language.upsert({
      where: { code: language.code },
      update: { name: language.name, isActive: true },
      create: language,
    });
  }

  // Region-rating system relations
  for (const mapping of regionRatingMappings) {
    const region = await prisma.region.findUniqueOrThrow({
      where: { slug: mapping.region },
    });

    for (const ratingSlug of mapping.ratings) {
      const rating = await prisma.ratingSystem.findUniqueOrThrow({
        where: { slug: ratingSlug },
      });

      await prisma.regionRatingSystem.upsert({
        where: {
          regionId_ratingSystemId: {
            regionId: region.id,
            ratingSystemId: rating.id,
          },
        },
        update: {},
        create: {
          regionId: region.id,
          ratingSystemId: rating.id,
        },
      });
    }
  }

  // Roles
  const roles = [
    {
      name: "User",
      slug: "user",
      description: "Standard registered user",
    },
    {
      name: "Moderator",
      slug: "moderator",
      description: "Catalog and community moderator",
    },
    {
      name: "Admin",
      slug: "admin",
      description: "Administrator with full system access",
    },
  ];

  const roleIds = new Map<string, string>();

  for (const role of roles) {
    const result = await prisma.role.upsert({
      where: { slug: role.slug },
      update: {
        name: role.name,
        description: role.description,
      },
      create: role,
    });

    roleIds.set(role.slug, result.id);
  }

  // Permissions
  const permissions = [
    {
      name: "View editions",
      slug: "edition.view",
      description: "View catalog editions",
    },
    {
      name: "Propose edition creation",
      slug: "edition.propose_create",
      description: "Propose a new catalog edition",
    },
    {
      name: "Propose edition updates",
      slug: "edition.propose_update",
      description: "Propose changes to an existing edition",
    },
    {
      name: "Create editions",
      slug: "edition.create",
      description: "Create catalog editions directly",
    },
    {
      name: "Update editions",
      slug: "edition.update",
      description: "Update catalog editions directly",
    },
    {
      name: "Delete editions",
      slug: "edition.delete",
      description: "Soft-delete catalog editions",
    },
    {
      name: "Restore editions",
      slug: "edition.restore",
      description: "Restore soft-deleted editions",
    },
    {
      name: "View all proposals",
      slug: "proposal.view_all",
      description: "View all change proposals",
    },
    {
      name: "Review proposals",
      slug: "proposal.review",
      description: "Approve or reject change proposals",
    },
    {
      name: "Cancel own proposals",
      slug: "proposal.cancel_own",
      description: "Cancel own pending proposals",
    },
    {
      name: "Manage dictionaries",
      slug: "dictionary.manage",
      description: "Manage catalog dictionaries",
    },
    {
      name: "View users",
      slug: "user.view",
      description: "View user accounts",
    },
    {
      name: "Suspend users",
      slug: "user.suspend",
      description: "Temporarily suspend user accounts",
    },
    {
      name: "Ban users",
      slug: "user.ban",
      description: "Permanently ban user accounts",
    },
    {
      name: "Manage user roles",
      slug: "user.manage_roles",
      description: "Assign and change user roles",
    },
    {
      name: "Manage users",
      slug: "user.manage",
      description: "Manage user accounts",
    },
    {
      name: "Create announcements",
      slug: "announcement.create",
      description: "Create site announcements",
    },
    {
      name: "Update announcements",
      slug: "announcement.update",
      description: "Update site announcements",
    },
    {
      name: "Archive announcements",
      slug: "announcement.archive",
      description: "Archive site announcements",
    },
  ];

  const permissionIds = new Map<string, string>();

  for (const permission of permissions) {
    const result = await prisma.permission.upsert({
      where: { slug: permission.slug },
      update: {
        name: permission.name,
        description: permission.description,
      },
      create: permission,
    });

    permissionIds.set(permission.slug, result.id);
  }

  // Role permissions
  const rolePermissionMap: Record<string, string[]> = {
    user: [
      "edition.view",
      "edition.propose_create",
      "edition.propose_update",
      "proposal.cancel_own",
    ],

    moderator: [
      "edition.view",
      "edition.propose_create",
      "edition.propose_update",
      "edition.create",
      "edition.update",
      "edition.delete",
      "edition.restore",
      "proposal.view_all",
      "proposal.review",
      "proposal.cancel_own",
      "user.view",
      "user.suspend",
      "announcement.create",
      "announcement.update",
      "announcement.archive",
    ],

    admin: permissions.map((permission) => permission.slug),
  };

  for (const [roleSlug, permissionSlugs] of Object.entries(rolePermissionMap)) {
    const roleId = roleIds.get(roleSlug);

    if (!roleId) {
      throw new Error(`Role not found: ${roleSlug}`);
    }

    for (const permissionSlug of permissionSlugs) {
      const permissionId = permissionIds.get(permissionSlug);

      if (!permissionId) {
        throw new Error(`Permission not found: ${permissionSlug}`);
      }

      await prisma.rolePermission.upsert({
        where: {
          roleId_permissionId: {
            roleId,
            permissionId,
          },
        },
        update: {},
        create: {
          roleId,
          permissionId,
        },
      });
    }
  }

  // Collection edition types
  const collectionEditionTypes = [
    {
      name: "Standard",
      slug: "standard",
    },
    {
      name: "Deluxe",
      slug: "deluxe",
    },
    {
      name: "Collector's",
      slug: "collectors",
    },
    {
      name: "GOTY",
      slug: "goty",
    },
    {
      name: "Steelbook",
      slug: "steelbook",
    },
    {
      name: "Limited",
      slug: "limited",
    },
    {
      name: "Ultimate",
      slug: "ultimate",
    },
  ];

  for (const editionType of collectionEditionTypes) {
    await prisma.collectionEditionType.upsert({
      where: {
        slug: editionType.slug,
      },
      update: {
        name: editionType.name,
        isActive: true,
      },
      create: editionType,
    });
  }

  console.log("Seed completed successfully.");
}

main()
  .catch((error) => {
    console.error("Seed failed:", error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
