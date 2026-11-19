-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('STUDENT', 'ORGANIZATION', 'PARTNER', 'ADMIN');

-- CreateEnum
CREATE TYPE "AccountStatus" AS ENUM ('ACTIVE', 'PENDING_EMAIL_VERIFICATION', 'REJECTED', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "AuthTokenType" AS ENUM ('RESET_PASSWORD', 'EMAIL_VERIFY');

-- CreateEnum
CREATE TYPE "StatusChangedBy" AS ENUM ('SYSTEM', 'ADMIN', 'USER');

-- CreateEnum
CREATE TYPE "SessionRevokeReason" AS ENUM ('LOGOUT', 'LOGOUT_ALL', 'REUSE_DETECTED', 'PASSWORD_CHANGE', 'SUSPENDED', 'ROLE_CHANGE', 'ADMIN');

-- CreateEnum
CREATE TYPE "Degree" AS ENUM ('DIPLOMA', 'ITI', 'BA', 'BSC', 'BCOM', 'BTECH_BE', 'BCA', 'BBA_BMS', 'BED', 'LLB', 'MBBS', 'BDS', 'BAMS_BHMS', 'BSC_NURSING', 'MA', 'MSC', 'MCOM', 'MTECH_ME', 'MCA', 'MBA_PGDM', 'MED', 'LLM', 'MD_MS', 'PHD', 'MPHIL', 'POST_DOC', 'OTHER');

-- CreateEnum
CREATE TYPE "Branch" AS ENUM ('AE', 'CE', 'Ch.E', 'CSE', 'EE', 'ECE', 'EIC', 'IT', 'ME', 'PE', 'PCE', 'P&I');

-- CreateEnum
CREATE TYPE "SocialPlatform" AS ENUM ('LINKEDIN', 'X', 'PORTFOLIO', 'GITHUB', 'YOUTUBE', 'TELEGRAM', 'WHATSAPP', 'DISCORD', 'FACEBOOK', 'REDDIT', 'PRODUCTHUNT', 'WELLFOUND', 'CRUNCHBASE', 'UPWORK', 'FIVERR', 'TOPTAL', 'BEHANCE', 'DRIBBBLE', 'INSTAGRAM', 'PINTEREST', 'MEDIUM', 'ARTSTATION', 'LINKTREE', 'LEETCODE', 'CODEFORCES', 'KAGGLE', 'STACKOVERFLOW', 'RESEARCHGATE', 'GOOGLE_SCHOLAR', 'SPOTIFY', 'SUBSTACK', 'OTHER');

-- CreateEnum
CREATE TYPE "VerificationStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ChangeRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "OrgSize" AS ENUM ('SOLO', 'SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE');

-- CreateEnum
CREATE TYPE "Industry" AS ENUM ('TECHNOLOGY_AND_IT', 'MANAGEMENT_CONSULTING', 'BFSI', 'MARKETING_AND_ADVERTISING', 'E_COMMERCE', 'ENGINEERING_AND_MANUFACTURING', 'CONSTRUCTION_AND_REAL_ESTATE', 'LOGISTICS_AND_SUPPLY_CHAIN', 'HEALTHCARE_AND_PHARMA', 'EDUCATION_AND_EDTECH', 'LEGAL_SERVICES', 'MEDIA_AND_ENTERTAINMENT', 'HOSPITALITY_AND_TOURISM', 'DESIGN_AND_CREATIVE', 'OTHER');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'PAUSED', 'CLOSED', 'EXPIRED', 'REMOVED');

-- CreateEnum
CREATE TYPE "WorkMode" AS ENUM ('ONSITE', 'REMOTE', 'HYBRID');

-- CreateEnum
CREATE TYPE "JobType" AS ENUM ('INTERNSHIP', 'FULL_TIME', 'PART_TIME', 'FELLOWSHIP');

-- CreateEnum
CREATE TYPE "ApplicationStatus" AS ENUM ('SUBMITTED', 'SHORTLISTED', 'INTERVIEWED', 'OFFERED', 'HIRED', 'REJECTED', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "ApplicationActor" AS ENUM ('STUDENT', 'ORGANIZATION', 'ADMIN', 'SYSTEM');

-- CreateEnum
CREATE TYPE "PartnerType" AS ENUM ('ECELL', 'COLLEGE', 'ENTREPRENEUR', 'MENTOR_SPEAKER', 'ALUMNI');

-- CreateEnum
CREATE TYPE "StartupStage" AS ENUM ('IDEA', 'MVP', 'EARLY_TRACTION', 'SCALING');

-- CreateEnum
CREATE TYPE "MentorshipStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'CANCELLED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "CollaborationDirection" AS ENUM ('INBOUND', 'OUTBOUND');

-- CreateEnum
CREATE TYPE "CollaborationType" AS ENUM ('ORGANIZE_EVENT', 'COLLABORATE_ON_EVENT', 'OTHER');

-- CreateEnum
CREATE TYPE "CollaborationStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ConversionBatchStatus" AS ENUM ('RUNNING', 'COMPLETED', 'COMPLETED_WITH_ERRORS', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AlumniConversionStatus" AS ENUM ('PENDING', 'CONVERTED', 'FAILED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "EventStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "EventMode" AS ENUM ('ONLINE', 'OFFLINE', 'HYBRID');

-- CreateEnum
CREATE TYPE "ParticipationType" AS ENUM ('INDIVIDUAL', 'TEAM');

-- CreateEnum
CREATE TYPE "RegistrationStatus" AS ENUM ('DRAFT', 'PENDING_PAYMENT', 'CONFIRMED', 'CANCELLED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "InviteStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('CREATED', 'PAID', 'FAILED', 'REFUND_PENDING', 'REFUNDED');

-- CreateEnum
CREATE TYPE "RegistrationActor" AS ENUM ('STUDENT', 'ADMIN', 'SYSTEM');

-- CreateEnum
CREATE TYPE "ExternalOpportunityType" AS ENUM ('HACKATHON', 'COMPETITION', 'INTERNSHIP', 'FELLOWSHIP', 'SCHOLARSHIP', 'PROGRAM', 'OTHER');

-- CreateEnum
CREATE TYPE "ExternalOpportunityStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "InitiativeStatus" AS ENUM ('DRAFT', 'PUBLISHED');

-- CreateEnum
CREATE TYPE "PatentStatus" AS ENUM ('NONE', 'FILED', 'GRANTED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "emailVerifiedAt" TIMESTAMP(3),
    "password" TEXT,
    "passwordChangedAt" TIMESTAMP(3),
    "googleId" TEXT,
    "role" "UserRole" NOT NULL,
    "status" "AccountStatus" NOT NULL DEFAULT 'PENDING_EMAIL_VERIFICATION',
    "lastLoginAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "refreshTokenHash" TEXT NOT NULL,
    "prevRefreshTokenHash" TEXT,
    "rotatedAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),
    "revokedReason" "SessionRevokeReason",
    "lastUsedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ipAddress" TEXT,
    "userAgent" TEXT,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuthToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "type" "AuthTokenType" NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuthToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StatusHistory" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "fromStatus" "AccountStatus",
    "toStatus" "AccountStatus" NOT NULL,
    "changedBy" "StatusChangedBy" NOT NULL,
    "changedById" TEXT,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StatusHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Student" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "fullName" TEXT,
    "profileImage" TEXT,
    "location" TEXT,
    "isRTUStudent" BOOLEAN,
    "collegeCode" TEXT,
    "collegeName" TEXT,
    "course" "Degree",
    "branch" "Branch",
    "graduationYear" INTEGER,
    "crNo" TEXT,
    "rollNo" TEXT,
    "phone" TEXT,
    "alternatePhone" TEXT,
    "alternateEmail" TEXT,
    "isOnboardingComplete" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "alumniConvertedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Student_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Resume" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "fileKey" TEXT NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "deletedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Resume_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialLink" (
    "id" TEXT NOT NULL,
    "platform" "SocialPlatform" NOT NULL,
    "url" TEXT NOT NULL,
    "customName" TEXT,
    "studentId" TEXT,
    "orgId" TEXT,
    "partnerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialLink_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VerificationHistory" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT,
    "partnerId" TEXT,
    "fromStatus" "VerificationStatus",
    "toStatus" "VerificationStatus" NOT NULL,
    "reviewedById" TEXT,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VerificationHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProfileChangeRequest" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT,
    "partnerId" TEXT,
    "changes" JSONB NOT NULL,
    "status" "ChangeRequestStatus" NOT NULL DEFAULT 'PENDING',
    "reviewedById" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ProfileChangeRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Organization" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'DRAFT',
    "submissionCount" INTEGER NOT NULL DEFAULT 0,
    "submittedAt" TIMESTAMP(3),
    "approvedAt" TIMESTAMP(3),
    "name" TEXT,
    "logo" TEXT,
    "banner" TEXT,
    "location" TEXT,
    "website" TEXT,
    "phone" TEXT,
    "alternatePhone" TEXT,
    "alternateEmail" TEXT,
    "contactPersonName" TEXT,
    "contactPersonDesignation" TEXT,
    "contactIdKey" TEXT,
    "tagline" TEXT,
    "about" TEXT,
    "foundingYear" INTEGER,
    "size" "OrgSize",
    "industry" "Industry",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Organization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Job" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "location" TEXT,
    "workMode" "WorkMode" NOT NULL,
    "jobType" "JobType" NOT NULL,
    "salary" INTEGER,
    "isSalaryDisclosed" BOOLEAN NOT NULL DEFAULT true,
    "isRtuOnly" BOOLEAN NOT NULL DEFAULT false,
    "minGraduationYear" INTEGER,
    "maxGraduationYear" INTEGER,
    "openings" INTEGER NOT NULL DEFAULT 1,
    "durationMonths" INTEGER,
    "deadline" TIMESTAMP(3),
    "status" "JobStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "closedAt" TIMESTAMP(3),
    "removedAt" TIMESTAMP(3),
    "removedById" TEXT,
    "removalReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Job_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Application" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "jobId" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "resumeId" TEXT NOT NULL,
    "status" "ApplicationStatus" NOT NULL DEFAULT 'SUBMITTED',
    "internalNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Application_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ApplicationStatusHistory" (
    "id" TEXT NOT NULL,
    "applicationId" TEXT NOT NULL,
    "fromStatus" "ApplicationStatus",
    "toStatus" "ApplicationStatus" NOT NULL,
    "actor" "ApplicationActor" NOT NULL,
    "changedByUserId" TEXT,
    "studentRemark" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ApplicationStatusHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Partner" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "partnerType" "PartnerType" NOT NULL,
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'DRAFT',
    "submissionCount" INTEGER NOT NULL DEFAULT 0,
    "submittedAt" TIMESTAMP(3),
    "approvedAt" TIMESTAMP(3),
    "convertedAt" TIMESTAMP(3),
    "name" TEXT,
    "image" TEXT,
    "banner" TEXT,
    "location" TEXT,
    "website" TEXT,
    "tagline" TEXT,
    "about" TEXT,
    "phone" TEXT,
    "alternatePhone" TEXT,
    "alternateEmail" TEXT,
    "mentorContactEmail" TEXT,
    "contactPersonName" TEXT,
    "contactPersonDesignation" TEXT,
    "contactIdKey" TEXT,
    "foundingYear" INTEGER,
    "collegeCode" TEXT,
    "collegeName" TEXT,
    "course" "Degree",
    "graduationYear" INTEGER,
    "currentRole" TEXT,
    "yearsOfExperience" INTEGER,
    "expertise" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "industry" "Industry",
    "isListed" BOOLEAN NOT NULL DEFAULT false,
    "isAcceptingRequests" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Partner_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Startup" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "partnerType" "PartnerType" NOT NULL DEFAULT 'ENTREPRENEUR',
    "name" TEXT NOT NULL,
    "description" TEXT,
    "logo" TEXT,
    "website" TEXT,
    "stage" "StartupStage" NOT NULL,
    "industry" "Industry" NOT NULL,
    "foundingYear" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Startup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MentorshipRequest" (
    "id" TEXT NOT NULL,
    "studentId" TEXT,
    "requesterAlumniId" TEXT,
    "requesterAlumniType" "PartnerType",
    "mentorId" TEXT NOT NULL,
    "mentorType" "PartnerType" NOT NULL,
    "message" TEXT NOT NULL,
    "status" "MentorshipStatus" NOT NULL DEFAULT 'PENDING',
    "responseNote" TEXT,
    "sharePhone" BOOLEAN NOT NULL DEFAULT false,
    "respondedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MentorshipRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CollaborationRequest" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "direction" "CollaborationDirection" NOT NULL,
    "type" "CollaborationType" NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "proposedDate" TIMESTAMP(3),
    "status" "CollaborationStatus" NOT NULL DEFAULT 'PENDING',
    "responseNote" TEXT,
    "respondedById" TEXT,
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CollaborationRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AlumniConversionBatch" (
    "id" TEXT NOT NULL,
    "triggeredById" TEXT,
    "graduationYear" INTEGER NOT NULL,
    "status" "ConversionBatchStatus" NOT NULL DEFAULT 'RUNNING',
    "totalCount" INTEGER NOT NULL DEFAULT 0,
    "convertedCount" INTEGER NOT NULL DEFAULT 0,
    "failedCount" INTEGER NOT NULL DEFAULT 0,
    "skippedCount" INTEGER NOT NULL DEFAULT 0,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "AlumniConversionBatch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AlumniConversion" (
    "id" TEXT NOT NULL,
    "batchId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "status" "AlumniConversionStatus" NOT NULL DEFAULT 'PENDING',
    "error" TEXT,
    "convertedAt" TIMESTAMP(3),
    "emailQueuedAt" TIMESTAMP(3),
    "emailSentAt" TIMESTAMP(3),
    "emailAttempts" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "AlumniConversion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Event" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT,
    "description" TEXT NOT NULL,
    "poster" TEXT,
    "galleryImages" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "videoLinks" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "mode" "EventMode" NOT NULL,
    "venue" TEXT,
    "onlineLink" TEXT,
    "date" TIMESTAMP(3) NOT NULL,
    "eligibleYears" INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    "isRtuOnly" BOOLEAN NOT NULL DEFAULT false,
    "participationType" "ParticipationType" NOT NULL DEFAULT 'INDIVIDUAL',
    "minTeamSize" INTEGER,
    "maxTeamSize" INTEGER,
    "registrationEnabled" BOOLEAN NOT NULL DEFAULT false,
    "registrationOpensAt" TIMESTAMP(3),
    "registrationClosesAt" TIMESTAMP(3),
    "feeAmount" INTEGER NOT NULL DEFAULT 0,
    "status" "EventStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "cancellationReason" TEXT,
    "createdById" TEXT,
    "hostPartnerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventRegistration" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "teamName" TEXT,
    "status" "RegistrationStatus" NOT NULL DEFAULT 'DRAFT',
    "feeAmount" INTEGER NOT NULL DEFAULT 0,
    "confirmedAt" TIMESTAMP(3),
    "cancelledAt" TIMESTAMP(3),
    "cancelReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EventRegistration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventRegistrationMember" (
    "id" TEXT NOT NULL,
    "registrationId" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "isLeader" BOOLEAN NOT NULL DEFAULT false,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leftAt" TIMESTAMP(3),
    "checkedInAt" TIMESTAMP(3),

    CONSTRAINT "EventRegistrationMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventTeamInvite" (
    "id" TEXT NOT NULL,
    "registrationId" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "invitedStudentId" TEXT NOT NULL,
    "status" "InviteStatus" NOT NULL DEFAULT 'PENDING',
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EventTeamInvite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "registrationId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'INR',
    "status" "PaymentStatus" NOT NULL DEFAULT 'CREATED',
    "gateway" TEXT NOT NULL DEFAULT 'RAZORPAY',
    "gatewayOrderId" TEXT NOT NULL,
    "gatewayPaymentId" TEXT,
    "method" TEXT,
    "failureReason" TEXT,
    "paidAt" TIMESTAMP(3),
    "refundId" TEXT,
    "refundedAmount" INTEGER NOT NULL DEFAULT 0,
    "refundedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaymentWebhookEvent" (
    "id" TEXT NOT NULL,
    "gateway" TEXT NOT NULL,
    "gatewayEventId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMP(3),
    "error" TEXT,

    CONSTRAINT "PaymentWebhookEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventRegistrationStatusHistory" (
    "id" TEXT NOT NULL,
    "registrationId" TEXT NOT NULL,
    "fromStatus" "RegistrationStatus",
    "toStatus" "RegistrationStatus" NOT NULL,
    "actor" "RegistrationActor" NOT NULL,
    "changedByUserId" TEXT,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EventRegistrationStatusHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExternalOpportunity" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "organizerName" TEXT NOT NULL,
    "shortDescription" TEXT NOT NULL,
    "applyLink" TEXT NOT NULL,
    "type" "ExternalOpportunityType" NOT NULL,
    "mode" "WorkMode" NOT NULL,
    "location" TEXT,
    "eligibleYears" INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    "deadline" TIMESTAMP(3),
    "startsAt" TIMESTAMP(3),
    "status" "ExternalOpportunityStatus" NOT NULL DEFAULT 'DRAFT',
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "clickCount" INTEGER NOT NULL DEFAULT 0,
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ExternalOpportunity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Innovation" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "shortDescription" TEXT NOT NULL,
    "thumbnail" TEXT,
    "hasDetailPage" BOOLEAN NOT NULL DEFAULT false,
    "description" TEXT,
    "galleryImages" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "videoLinks" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "members" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "year" INTEGER NOT NULL,
    "demoUrl" TEXT,
    "patentStatus" "PatentStatus" NOT NULL DEFAULT 'NONE',
    "displayOrder" INTEGER NOT NULL DEFAULT 0,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "status" "InitiativeStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Innovation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Incubation" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "shortDescription" TEXT NOT NULL,
    "logo" TEXT,
    "website" TEXT,
    "founders" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "incubatedYear" INTEGER NOT NULL,
    "sector" "Industry" NOT NULL,
    "displayOrder" INTEGER NOT NULL DEFAULT 0,
    "isFeatured" BOOLEAN NOT NULL DEFAULT false,
    "status" "InitiativeStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Incubation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_googleId_key" ON "User"("googleId");

-- CreateIndex
CREATE INDEX "User_role_idx" ON "User"("role");

-- CreateIndex
CREATE INDEX "User_status_idx" ON "User"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Session_refreshTokenHash_key" ON "Session"("refreshTokenHash");

-- CreateIndex
CREATE UNIQUE INDEX "Session_prevRefreshTokenHash_key" ON "Session"("prevRefreshTokenHash");

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE INDEX "Session_expiresAt_idx" ON "Session"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "AuthToken_tokenHash_key" ON "AuthToken"("tokenHash");

-- CreateIndex
CREATE INDEX "AuthToken_userId_type_idx" ON "AuthToken"("userId", "type");

-- CreateIndex
CREATE INDEX "AuthToken_expiresAt_idx" ON "AuthToken"("expiresAt");

-- CreateIndex
CREATE INDEX "StatusHistory_userId_createdAt_idx" ON "StatusHistory"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Student_userId_key" ON "Student"("userId");

-- CreateIndex
CREATE INDEX "Student_collegeCode_graduationYear_idx" ON "Student"("collegeCode", "graduationYear");

-- CreateIndex
CREATE UNIQUE INDEX "Student_collegeCode_rollNo_key" ON "Student"("collegeCode", "rollNo");

-- CreateIndex
CREATE UNIQUE INDEX "Student_collegeCode_crNo_key" ON "Student"("collegeCode", "crNo");

-- CreateIndex
CREATE INDEX "Resume_studentId_idx" ON "Resume"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "Resume_id_studentId_key" ON "Resume"("id", "studentId");

-- CreateIndex
CREATE INDEX "SocialLink_studentId_idx" ON "SocialLink"("studentId");

-- CreateIndex
CREATE INDEX "SocialLink_orgId_idx" ON "SocialLink"("orgId");

-- CreateIndex
CREATE INDEX "SocialLink_partnerId_idx" ON "SocialLink"("partnerId");

-- CreateIndex
CREATE INDEX "VerificationHistory_organizationId_createdAt_idx" ON "VerificationHistory"("organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "VerificationHistory_partnerId_createdAt_idx" ON "VerificationHistory"("partnerId", "createdAt");

-- CreateIndex
CREATE INDEX "ProfileChangeRequest_organizationId_status_idx" ON "ProfileChangeRequest"("organizationId", "status");

-- CreateIndex
CREATE INDEX "ProfileChangeRequest_partnerId_status_idx" ON "ProfileChangeRequest"("partnerId", "status");

-- CreateIndex
CREATE INDEX "ProfileChangeRequest_status_createdAt_idx" ON "ProfileChangeRequest"("status", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Organization_userId_key" ON "Organization"("userId");

-- CreateIndex
CREATE INDEX "Organization_verificationStatus_idx" ON "Organization"("verificationStatus");

-- CreateIndex
CREATE INDEX "Job_status_publishedAt_idx" ON "Job"("status", "publishedAt" DESC);

-- CreateIndex
CREATE INDEX "Job_organizationId_status_idx" ON "Job"("organizationId", "status");

-- CreateIndex
CREATE INDEX "Job_deadline_idx" ON "Job"("deadline");

-- CreateIndex
CREATE UNIQUE INDEX "Job_id_organizationId_key" ON "Job"("id", "organizationId");

-- CreateIndex
CREATE INDEX "Application_jobId_status_idx" ON "Application"("jobId", "status");

-- CreateIndex
CREATE INDEX "Application_organizationId_status_idx" ON "Application"("organizationId", "status");

-- CreateIndex
CREATE INDEX "Application_studentId_createdAt_idx" ON "Application"("studentId", "createdAt");

-- CreateIndex
CREATE INDEX "Application_resumeId_idx" ON "Application"("resumeId");

-- CreateIndex
CREATE UNIQUE INDEX "Application_studentId_jobId_key" ON "Application"("studentId", "jobId");

-- CreateIndex
CREATE INDEX "ApplicationStatusHistory_applicationId_createdAt_idx" ON "ApplicationStatusHistory"("applicationId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Partner_userId_key" ON "Partner"("userId");

-- CreateIndex
CREATE INDEX "Partner_partnerType_verificationStatus_idx" ON "Partner"("partnerType", "verificationStatus");

-- CreateIndex
CREATE INDEX "Partner_verificationStatus_idx" ON "Partner"("verificationStatus");

-- CreateIndex
CREATE INDEX "Partner_collegeCode_idx" ON "Partner"("collegeCode");

-- CreateIndex
CREATE UNIQUE INDEX "Partner_id_partnerType_key" ON "Partner"("id", "partnerType");

-- CreateIndex
CREATE INDEX "Startup_partnerId_idx" ON "Startup"("partnerId");

-- CreateIndex
CREATE UNIQUE INDEX "Startup_partnerId_name_key" ON "Startup"("partnerId", "name");

-- CreateIndex
CREATE INDEX "MentorshipRequest_mentorId_status_createdAt_idx" ON "MentorshipRequest"("mentorId", "status", "createdAt");

-- CreateIndex
CREATE INDEX "MentorshipRequest_studentId_createdAt_idx" ON "MentorshipRequest"("studentId", "createdAt");

-- CreateIndex
CREATE INDEX "MentorshipRequest_studentId_mentorId_createdAt_idx" ON "MentorshipRequest"("studentId", "mentorId", "createdAt");

-- CreateIndex
CREATE INDEX "MentorshipRequest_requesterAlumniId_createdAt_idx" ON "MentorshipRequest"("requesterAlumniId", "createdAt");

-- CreateIndex
CREATE INDEX "MentorshipRequest_requesterAlumniId_mentorId_createdAt_idx" ON "MentorshipRequest"("requesterAlumniId", "mentorId", "createdAt");

-- CreateIndex
CREATE INDEX "CollaborationRequest_status_createdAt_idx" ON "CollaborationRequest"("status", "createdAt");

-- CreateIndex
CREATE INDEX "CollaborationRequest_partnerId_createdAt_idx" ON "CollaborationRequest"("partnerId", "createdAt");

-- CreateIndex
CREATE INDEX "AlumniConversionBatch_status_idx" ON "AlumniConversionBatch"("status");

-- CreateIndex
CREATE INDEX "AlumniConversion_batchId_status_idx" ON "AlumniConversion"("batchId", "status");

-- CreateIndex
CREATE INDEX "AlumniConversion_emailQueuedAt_emailSentAt_idx" ON "AlumniConversion"("emailQueuedAt", "emailSentAt");

-- CreateIndex
CREATE UNIQUE INDEX "AlumniConversion_batchId_userId_key" ON "AlumniConversion"("batchId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "Event_slug_key" ON "Event"("slug");

-- CreateIndex
CREATE INDEX "Event_status_date_idx" ON "Event"("status", "date" DESC);

-- CreateIndex
CREATE INDEX "Event_hostPartnerId_idx" ON "Event"("hostPartnerId");

-- CreateIndex
CREATE INDEX "EventRegistration_eventId_status_idx" ON "EventRegistration"("eventId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "EventRegistration_id_eventId_key" ON "EventRegistration"("id", "eventId");

-- CreateIndex
CREATE INDEX "EventRegistrationMember_studentId_joinedAt_idx" ON "EventRegistrationMember"("studentId", "joinedAt");

-- CreateIndex
CREATE INDEX "EventRegistrationMember_eventId_idx" ON "EventRegistrationMember"("eventId");

-- CreateIndex
CREATE INDEX "EventRegistrationMember_registrationId_leftAt_idx" ON "EventRegistrationMember"("registrationId", "leftAt");

-- CreateIndex
CREATE INDEX "EventTeamInvite_invitedStudentId_eventId_status_idx" ON "EventTeamInvite"("invitedStudentId", "eventId", "status");

-- CreateIndex
CREATE INDEX "EventTeamInvite_registrationId_status_idx" ON "EventTeamInvite"("registrationId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "EventTeamInvite_registrationId_invitedStudentId_key" ON "EventTeamInvite"("registrationId", "invitedStudentId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_gatewayOrderId_key" ON "Payment"("gatewayOrderId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_gatewayPaymentId_key" ON "Payment"("gatewayPaymentId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_refundId_key" ON "Payment"("refundId");

-- CreateIndex
CREATE INDEX "Payment_registrationId_status_idx" ON "Payment"("registrationId", "status");

-- CreateIndex
CREATE INDEX "Payment_status_createdAt_idx" ON "Payment"("status", "createdAt");

-- CreateIndex
CREATE INDEX "PaymentWebhookEvent_processedAt_idx" ON "PaymentWebhookEvent"("processedAt");

-- CreateIndex
CREATE UNIQUE INDEX "PaymentWebhookEvent_gateway_gatewayEventId_key" ON "PaymentWebhookEvent"("gateway", "gatewayEventId");

-- CreateIndex
CREATE INDEX "EventRegistrationStatusHistory_registrationId_createdAt_idx" ON "EventRegistrationStatusHistory"("registrationId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "ExternalOpportunity_applyLink_key" ON "ExternalOpportunity"("applyLink");

-- CreateIndex
CREATE INDEX "ExternalOpportunity_status_deadline_idx" ON "ExternalOpportunity"("status", "deadline");

-- CreateIndex
CREATE INDEX "ExternalOpportunity_status_type_idx" ON "ExternalOpportunity"("status", "type");

-- CreateIndex
CREATE UNIQUE INDEX "Innovation_slug_key" ON "Innovation"("slug");

-- CreateIndex
CREATE INDEX "Innovation_status_displayOrder_idx" ON "Innovation"("status", "displayOrder");

-- CreateIndex
CREATE INDEX "Innovation_status_isFeatured_idx" ON "Innovation"("status", "isFeatured");

-- CreateIndex
CREATE UNIQUE INDEX "Incubation_title_key" ON "Incubation"("title");

-- CreateIndex
CREATE INDEX "Incubation_status_displayOrder_idx" ON "Incubation"("status", "displayOrder");

-- CreateIndex
CREATE INDEX "Incubation_status_isFeatured_idx" ON "Incubation"("status", "isFeatured");

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuthToken" ADD CONSTRAINT "AuthToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StatusHistory" ADD CONSTRAINT "StatusHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StatusHistory" ADD CONSTRAINT "StatusHistory_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Student" ADD CONSTRAINT "Student_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Resume" ADD CONSTRAINT "Resume_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialLink" ADD CONSTRAINT "SocialLink_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialLink" ADD CONSTRAINT "SocialLink_orgId_fkey" FOREIGN KEY ("orgId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialLink" ADD CONSTRAINT "SocialLink_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VerificationHistory" ADD CONSTRAINT "VerificationHistory_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VerificationHistory" ADD CONSTRAINT "VerificationHistory_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VerificationHistory" ADD CONSTRAINT "VerificationHistory_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileChangeRequest" ADD CONSTRAINT "ProfileChangeRequest_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileChangeRequest" ADD CONSTRAINT "ProfileChangeRequest_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileChangeRequest" ADD CONSTRAINT "ProfileChangeRequest_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Organization" ADD CONSTRAINT "Organization_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_removedById_fkey" FOREIGN KEY ("removedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" ADD CONSTRAINT "Application_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" ADD CONSTRAINT "Application_jobId_organizationId_fkey" FOREIGN KEY ("jobId", "organizationId") REFERENCES "Job"("id", "organizationId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" ADD CONSTRAINT "Application_resumeId_studentId_fkey" FOREIGN KEY ("resumeId", "studentId") REFERENCES "Resume"("id", "studentId") ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApplicationStatusHistory" ADD CONSTRAINT "ApplicationStatusHistory_applicationId_fkey" FOREIGN KEY ("applicationId") REFERENCES "Application"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApplicationStatusHistory" ADD CONSTRAINT "ApplicationStatusHistory_changedByUserId_fkey" FOREIGN KEY ("changedByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Partner" ADD CONSTRAINT "Partner_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Startup" ADD CONSTRAINT "Startup_partnerId_partnerType_fkey" FOREIGN KEY ("partnerId", "partnerType") REFERENCES "Partner"("id", "partnerType") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MentorshipRequest" ADD CONSTRAINT "MentorshipRequest_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MentorshipRequest" ADD CONSTRAINT "MentorshipRequest_requesterAlumniId_requesterAlumniType_fkey" FOREIGN KEY ("requesterAlumniId", "requesterAlumniType") REFERENCES "Partner"("id", "partnerType") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MentorshipRequest" ADD CONSTRAINT "MentorshipRequest_mentorId_mentorType_fkey" FOREIGN KEY ("mentorId", "mentorType") REFERENCES "Partner"("id", "partnerType") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CollaborationRequest" ADD CONSTRAINT "CollaborationRequest_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CollaborationRequest" ADD CONSTRAINT "CollaborationRequest_respondedById_fkey" FOREIGN KEY ("respondedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AlumniConversionBatch" ADD CONSTRAINT "AlumniConversionBatch_triggeredById_fkey" FOREIGN KEY ("triggeredById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AlumniConversion" ADD CONSTRAINT "AlumniConversion_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "AlumniConversionBatch"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AlumniConversion" ADD CONSTRAINT "AlumniConversion_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_hostPartnerId_fkey" FOREIGN KEY ("hostPartnerId") REFERENCES "Partner"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventRegistration" ADD CONSTRAINT "EventRegistration_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "Event"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventRegistrationMember" ADD CONSTRAINT "EventRegistrationMember_registrationId_eventId_fkey" FOREIGN KEY ("registrationId", "eventId") REFERENCES "EventRegistration"("id", "eventId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventRegistrationMember" ADD CONSTRAINT "EventRegistrationMember_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "Student"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventTeamInvite" ADD CONSTRAINT "EventTeamInvite_registrationId_eventId_fkey" FOREIGN KEY ("registrationId", "eventId") REFERENCES "EventRegistration"("id", "eventId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventTeamInvite" ADD CONSTRAINT "EventTeamInvite_invitedStudentId_fkey" FOREIGN KEY ("invitedStudentId") REFERENCES "Student"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_registrationId_fkey" FOREIGN KEY ("registrationId") REFERENCES "EventRegistration"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventRegistrationStatusHistory" ADD CONSTRAINT "EventRegistrationStatusHistory_registrationId_fkey" FOREIGN KEY ("registrationId") REFERENCES "EventRegistration"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventRegistrationStatusHistory" ADD CONSTRAINT "EventRegistrationStatusHistory_changedByUserId_fkey" FOREIGN KEY ("changedByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;


-- =====================================================================
-- Constraints, partial indexes and triggers that Prisma cannot express.
-- Table and column names are quoted because Prisma creates them camelCase.
-- The API must enforce the same rules (Zod); the DB is the last line of defence.
-- =====================================================================

-- ---------------------------------------------------------------------
-- USER
-- ---------------------------------------------------------------------

-- Email must already be normalized by the app. This makes a forgotten normalize a hard error.
ALTER TABLE "User" ADD CONSTRAINT user_email_normalized
  CHECK ("email" = lower(btrim("email")));

-- A live account must have some way to log in (deleted/anonymized accounts are exempt).
ALTER TABLE "User" ADD CONSTRAINT user_has_login_method
  CHECK ("deletedAt" IS NOT NULL OR "password" IS NOT NULL OR "googleId" IS NOT NULL);

-- ACTIVE accounts always have a verified email (link clicked, or Google).
-- NOTE: the seeded admin must also have emailVerifiedAt set.
ALTER TABLE "User" ADD CONSTRAINT user_active_requires_verified_email
  CHECK ("status" <> 'ACTIVE' OR "emailVerifiedAt" IS NOT NULL);

-- Exactly one admin can ever exist.
CREATE UNIQUE INDEX one_admin_only ON "User" ("role") WHERE "role" = 'ADMIN';

-- role never changes. The ONLY exception: the admin's alumni conversion (STUDENT -> PARTNER),
-- which must run inside a transaction that did: SET LOCAL app.alumni_conversion = 'on'
CREATE FUNCTION user_role_guard() RETURNS trigger AS $$
BEGIN
  IF NEW."role" IS DISTINCT FROM OLD."role" THEN
    IF NOT (OLD."role" = 'STUDENT' AND NEW."role" = 'PARTNER'
            AND COALESCE(current_setting('app.alumni_conversion', true), '') = 'on') THEN
      RAISE EXCEPTION 'role never changes (only the alumni conversion may change STUDENT to PARTNER)';
    END IF;
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER user_role_guard_trg BEFORE UPDATE ON "User"
  FOR EACH ROW EXECUTE FUNCTION user_role_guard();

-- ---------------------------------------------------------------------
-- Student
-- ---------------------------------------------------------------------

-- A row can only be flagged complete when the required fields are filled.
ALTER TABLE "Student" ADD CONSTRAINT student_onboarding_requires_fields
  CHECK (
    NOT "isOnboardingComplete"
    OR (
      "fullName" IS NOT NULL
      AND "isRTUStudent" IS NOT NULL
      AND "collegeName" IS NOT NULL
      AND "course" IS NOT NULL
      AND "graduationYear" IS NOT NULL
      AND "phone" IS NOT NULL
      AND (
        NOT (COALESCE("isRTUStudent", false) AND "course" IS NOT DISTINCT FROM 'BTECH_BE')
        OR "branch" IS NOT NULL
      )
    )
  );

-- RTU students must always come from the dataset (server sets the code).
ALTER TABLE "Student" ADD CONSTRAINT student_rtu_has_college_code
  CHECK (NOT COALESCE("isRTUStudent", false) OR "collegeCode" IS NOT NULL);

-- Branch exists only for RTU B.Tech students.
ALTER TABLE "Student" ADD CONSTRAINT student_branch_only_rtu_btech
  CHECK (
    "branch" IS NULL
    OR (COALESCE("isRTUStudent", false) AND "course" IS NOT DISTINCT FROM 'BTECH_BE')
  );

-- Roll numbers stored uppercase/trimmed; RTU roll numbers must contain UC.
-- TODO: replace LIKE '%UC%' with a strict regex once the exact roll number format is known.
ALTER TABLE "Student" ADD CONSTRAINT student_rollno_normalized
  CHECK ("rollNo" IS NULL OR "rollNo" = upper(btrim("rollNo")));
ALTER TABLE "Student" ADD CONSTRAINT student_crno_normalized
  CHECK ("crNo" IS NULL OR "crNo" = upper(btrim("crNo")));
ALTER TABLE "Student" ADD CONSTRAINT student_rollno_not_blank
  CHECK ("rollNo" IS NULL OR btrim("rollNo") <> '');
ALTER TABLE "Student" ADD CONSTRAINT student_crno_not_blank
  CHECK ("crNo" IS NULL OR btrim("crNo") <> '');
ALTER TABLE "Student" ADD CONSTRAINT student_rtu_rollno_has_uc
  CHECK ("rollNo" IS NULL OR NOT COALESCE("isRTUStudent", false) OR "rollNo" LIKE '%UC%');

-- Phone numbers in E.164 (+ then 8 to 15 digits).
ALTER TABLE "Student" ADD CONSTRAINT student_phone_e164
  CHECK ("phone" IS NULL OR "phone" ~ '^\+[1-9][0-9]{7,14}$');
ALTER TABLE "Student" ADD CONSTRAINT student_alt_phone_e164
  CHECK ("alternatePhone" IS NULL OR "alternatePhone" ~ '^\+[1-9][0-9]{7,14}$');

-- Alternate email normalized, graduation year sane, location length capped.
ALTER TABLE "Student" ADD CONSTRAINT student_alt_email_normalized
  CHECK ("alternateEmail" IS NULL OR "alternateEmail" = lower(btrim("alternateEmail")));
ALTER TABLE "Student" ADD CONSTRAINT student_graduation_year_range
  CHECK ("graduationYear" IS NULL OR "graduationYear" BETWEEN 2000 AND 2100);
ALTER TABLE "Student" ADD CONSTRAINT student_location_length
  CHECK ("location" IS NULL OR char_length("location") <= 150);

-- ---------------------------------------------------------------------
-- Resume
-- ---------------------------------------------------------------------

-- Only one live primary resume per student.
-- To switch primary: in ONE transaction, first unset the old one, then set the new one.
CREATE UNIQUE INDEX resume_one_primary_per_student
  ON "Resume" ("studentId")
  WHERE "isPrimary" AND "deletedAt" IS NULL;

-- ---------------------------------------------------------------------
-- Social Links
-- ---------------------------------------------------------------------

-- Exactly one owner.
ALTER TABLE "SocialLink" ADD CONSTRAINT social_exactly_one_owner
  CHECK (num_nonnulls("studentId", "orgId", "partnerId") = 1);

-- customName present if and only if platform = OTHER.
ALTER TABLE "SocialLink" ADD CONSTRAINT social_custom_name_only_other
  CHECK (("platform" = 'OTHER') = ("customName" IS NOT NULL));

-- https links only (the API also checks the host matches the platform).
ALTER TABLE "SocialLink" ADD CONSTRAINT social_url_https
  CHECK ("url" ~* '^https://');

-- One link per platform per owner, except OTHER which can repeat.
CREATE UNIQUE INDEX social_student_platform_unique
  ON "SocialLink" ("studentId", "platform")
  WHERE "studentId" IS NOT NULL AND "platform" <> 'OTHER';
CREATE UNIQUE INDEX social_org_platform_unique
  ON "SocialLink" ("orgId", "platform")
  WHERE "orgId" IS NOT NULL AND "platform" <> 'OTHER';
CREATE UNIQUE INDEX social_partner_platform_unique
  ON "SocialLink" ("partnerId", "platform")
  WHERE "partnerId" IS NOT NULL AND "platform" <> 'OTHER';

-- ---------------------------------------------------------------------
-- Organization
-- ---------------------------------------------------------------------

-- Core fields must be filled once the org is SUBMITTED or APPROVED.
ALTER TABLE "Organization" ADD CONSTRAINT org_submitted_requires_fields
  CHECK (
    "verificationStatus" IN ('DRAFT', 'REJECTED')
    OR (
      "name" IS NOT NULL AND "location" IS NOT NULL AND "website" IS NOT NULL
      AND "phone" IS NOT NULL AND "about" IS NOT NULL AND "foundingYear" IS NOT NULL
      AND "size" IS NOT NULL AND "industry" IS NOT NULL
      AND "contactPersonName" IS NOT NULL AND "contactPersonDesignation" IS NOT NULL
    )
  );
-- The contact person's ID file is required only while under review (it is deleted at the decision)
ALTER TABLE "Organization" ADD CONSTRAINT org_submitted_has_id
  CHECK ("verificationStatus" <> 'SUBMITTED' OR "contactIdKey" IS NOT NULL);
ALTER TABLE "Organization" ADD CONSTRAINT org_approved_has_date
  CHECK ("verificationStatus" <> 'APPROVED' OR "approvedAt" IS NOT NULL);
ALTER TABLE "Organization" ADD CONSTRAINT org_website_https
  CHECK ("website" IS NULL OR "website" ~* '^https://');
ALTER TABLE "Organization" ADD CONSTRAINT org_phone_e164
  CHECK ("phone" IS NULL OR "phone" ~ '^\+[1-9][0-9]{7,14}$');
ALTER TABLE "Organization" ADD CONSTRAINT org_alt_phone_e164
  CHECK ("alternatePhone" IS NULL OR "alternatePhone" ~ '^\+[1-9][0-9]{7,14}$');
ALTER TABLE "Organization" ADD CONSTRAINT org_alt_email_normalized
  CHECK ("alternateEmail" IS NULL OR "alternateEmail" = lower(btrim("alternateEmail")));
ALTER TABLE "Organization" ADD CONSTRAINT org_founding_year_range
  CHECK ("foundingYear" IS NULL OR "foundingYear" BETWEEN 1800 AND 2100); -- API also rejects future years
ALTER TABLE "Organization" ADD CONSTRAINT org_text_lengths
  CHECK (
    char_length("name") <= 120 AND char_length("tagline") <= 150
    AND char_length("about") <= 3000 AND char_length("location") <= 150
    AND char_length("contactPersonName") <= 120 AND char_length("contactPersonDesignation") <= 100
  );

-- Name is locked after first approval; no edits at all while under review.
CREATE FUNCTION org_guard() RETURNS trigger AS $$
BEGIN
  IF OLD."approvedAt" IS NOT NULL AND NEW."name" IS DISTINCT FROM OLD."name" THEN
    RAISE EXCEPTION 'Organization name is locked after approval';
  END IF;
  IF OLD."verificationStatus" = 'SUBMITTED' AND NEW."verificationStatus" = 'SUBMITTED'
     AND (to_jsonb(NEW) - 'updatedAt') IS DISTINCT FROM (to_jsonb(OLD) - 'updatedAt') THEN
    RAISE EXCEPTION 'Organization is locked while under review';
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER org_guard_trg BEFORE UPDATE ON "Organization"
  FOR EACH ROW EXECUTE FUNCTION org_guard();
-- To fix a typo in an approved name, the admin must do it deliberately in SQL (disable the trigger, fix, re-enable).

-- ---------------------------------------------------------------------
-- Shared Verification Table
-- ---------------------------------------------------------------------

ALTER TABLE "VerificationHistory" ADD CONSTRAINT verification_history_one_owner
  CHECK (num_nonnulls("organizationId", "partnerId") = 1);
ALTER TABLE "ProfileChangeRequest" ADD CONSTRAINT change_request_one_owner
  CHECK (num_nonnulls("organizationId", "partnerId") = 1);
ALTER TABLE "ProfileChangeRequest" ADD CONSTRAINT change_request_is_object
  CHECK (jsonb_typeof("changes") = 'object');
-- Only one pending request per owner.
CREATE UNIQUE INDEX org_one_pending_change ON "ProfileChangeRequest" ("organizationId")
  WHERE "organizationId" IS NOT NULL AND "status" = 'PENDING';
CREATE UNIQUE INDEX partner_one_pending_change ON "ProfileChangeRequest" ("partnerId")
  WHERE "partnerId" IS NOT NULL AND "status" = 'PENDING';

-- ---------------------------------------------------------------------
-- Job
-- ---------------------------------------------------------------------

ALTER TABLE "Job" ADD CONSTRAINT job_location_unless_remote
  CHECK ("workMode" = 'REMOTE' OR "location" IS NOT NULL);
ALTER TABLE "Job" ADD CONSTRAINT job_salary_non_negative
  CHECK ("salary" IS NULL OR "salary" >= 0);
ALTER TABLE "Job" ADD CONSTRAINT job_openings_range
  CHECK ("openings" BETWEEN 1 AND 1000);
ALTER TABLE "Job" ADD CONSTRAINT job_duration_rules
  CHECK (
    ("jobType" <> 'INTERNSHIP' OR "durationMonths" IS NOT NULL)
    AND ("durationMonths" IS NULL OR "durationMonths" BETWEEN 1 AND 36)
  );
ALTER TABLE "Job" ADD CONSTRAINT job_graduation_year_rules
  CHECK (
    ("minGraduationYear" IS NULL OR "minGraduationYear" BETWEEN 2000 AND 2100)
    AND ("maxGraduationYear" IS NULL OR "maxGraduationYear" BETWEEN 2000 AND 2100)
    AND ("minGraduationYear" IS NULL OR "maxGraduationYear" IS NULL OR "minGraduationYear" <= "maxGraduationYear")
  );
ALTER TABLE "Job" ADD CONSTRAINT job_published_has_date
  CHECK ("status" NOT IN ('PUBLISHED', 'PAUSED') OR "publishedAt" IS NOT NULL);
ALTER TABLE "Job" ADD CONSTRAINT job_removed_has_audit
  CHECK ("status" <> 'REMOVED' OR ("removedAt" IS NOT NULL AND "removalReason" IS NOT NULL));
ALTER TABLE "Job" ADD CONSTRAINT job_text_lengths
  CHECK (char_length("title") <= 150 AND char_length("description") <= 10000);

-- Core terms are locked once the job has its first application.
-- description, openings, deadline and status stay editable.
CREATE FUNCTION job_lock_after_applications() RETURNS trigger AS $$
BEGIN
  IF (
    NEW."title" IS DISTINCT FROM OLD."title"
    OR NEW."jobType" IS DISTINCT FROM OLD."jobType"
    OR NEW."workMode" IS DISTINCT FROM OLD."workMode"
    OR NEW."location" IS DISTINCT FROM OLD."location"
    OR NEW."salary" IS DISTINCT FROM OLD."salary"
    OR NEW."isSalaryDisclosed" IS DISTINCT FROM OLD."isSalaryDisclosed"
    OR NEW."durationMonths" IS DISTINCT FROM OLD."durationMonths"
    OR NEW."isRtuOnly" IS DISTINCT FROM OLD."isRtuOnly"
    OR NEW."minGraduationYear" IS DISTINCT FROM OLD."minGraduationYear"
    OR NEW."maxGraduationYear" IS DISTINCT FROM OLD."maxGraduationYear"
  ) AND EXISTS (SELECT 1 FROM "Application" WHERE "jobId" = OLD."id") THEN
    RAISE EXCEPTION 'Job terms are locked once it has applications';
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER job_lock_trg BEFORE UPDATE ON "Job"
  FOR EACH ROW EXECUTE FUNCTION job_lock_after_applications();

-- ---------------------------------------------------------------------
-- Application
-- ---------------------------------------------------------------------

ALTER TABLE "Application" ADD CONSTRAINT application_note_length
  CHECK (char_length("internalNote") <= 2000);
ALTER TABLE "ApplicationStatusHistory" ADD CONSTRAINT app_history_remark_length
  CHECK (char_length("studentRemark") <= 1000);

-- ---------------------------------------------------------------------
-- Append-only history tables
-- ---------------------------------------------------------------------

-- Blocks UPDATE only. Deletes still work so cascades don't break.
CREATE FUNCTION forbid_update() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION '% rows are append-only', TG_TABLE_NAME;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER status_history_append_only BEFORE UPDATE ON "StatusHistory"
  FOR EACH ROW EXECUTE FUNCTION forbid_update();
CREATE TRIGGER verification_history_append_only BEFORE UPDATE ON "VerificationHistory"
  FOR EACH ROW EXECUTE FUNCTION forbid_update();
CREATE TRIGGER application_status_history_append_only BEFORE UPDATE ON "ApplicationStatusHistory"
  FOR EACH ROW EXECUTE FUNCTION forbid_update();
CREATE TRIGGER event_registration_status_history_append_only BEFORE UPDATE ON "EventRegistrationStatusHistory"
  FOR EACH ROW EXECUTE FUNCTION forbid_update();

-- ---------------------------------------------------------------------
-- Partner
-- ---------------------------------------------------------------------

CREATE FUNCTION max_text_len(arr text[]) RETURNS int AS $$
  SELECT COALESCE(max(char_length(e)), 0) FROM unnest(arr) AS e
$$ LANGUAGE sql IMMUTABLE;

-- Type-specific fields exist only on their type
ALTER TABLE "Partner" ADD CONSTRAINT partner_type_specific_fields CHECK (
  ("partnerType" IN ('ECELL','COLLEGE') OR ("contactPersonName" IS NULL AND "contactPersonDesignation" IS NULL
     AND "contactIdKey" IS NULL AND "foundingYear" IS NULL))
  AND ("partnerType" IN ('ECELL','COLLEGE','ALUMNI') OR ("collegeCode" IS NULL AND "collegeName" IS NULL))
  AND ("partnerType" = 'ALUMNI' OR ("course" IS NULL AND "graduationYear" IS NULL))
  AND ("partnerType" IN ('MENTOR_SPEAKER','ALUMNI') OR ("mentorContactEmail" IS NULL AND "currentRole" IS NULL
     AND "yearsOfExperience" IS NULL AND "industry" IS NULL AND "mentorContactEmail" IS NULL AND COALESCE(cardinality("expertise"), 0) = 0))
);

-- Required once SUBMITTED or APPROVED
ALTER TABLE "Partner" ADD CONSTRAINT partner_submitted_requires_fields CHECK (
  "verificationStatus" IN ('DRAFT','REJECTED')
  OR "convertedAt" IS NOT NULL -- converted alumni are approved without these fields, see partner_converted_rules below
  OR (
    "name" IS NOT NULL AND "location" IS NOT NULL AND "about" IS NOT NULL AND "phone" IS NOT NULL
    AND ("partnerType" NOT IN ('ECELL','COLLEGE') OR ("collegeCode" IS NOT NULL AND "collegeName" IS NOT NULL
         AND "contactPersonName" IS NOT NULL AND "contactPersonDesignation" IS NOT NULL))
    AND ("partnerType" <> 'ALUMNI' OR ("collegeCode" IS NOT NULL AND "collegeName" IS NOT NULL
         AND "course" IS NOT NULL AND "graduationYear" IS NOT NULL AND "mentorContactEmail" IS NOT NULL))
    AND ("partnerType" <> 'MENTOR_SPEAKER' OR ("currentRole" IS NOT NULL AND "mentorContactEmail" IS NOT NULL
         AND COALESCE(cardinality("expertise"), 0) > 0))
  )
);
-- The entity's ID file is required only while under review (it is deleted at the decision)
ALTER TABLE "Partner" ADD CONSTRAINT partner_submitted_entity_has_id
  CHECK ("verificationStatus" <> 'SUBMITTED' OR "partnerType" NOT IN ('ECELL','COLLEGE') OR "contactIdKey" IS NOT NULL);
ALTER TABLE "Partner" ADD CONSTRAINT partner_approved_has_date
  CHECK ("verificationStatus" <> 'APPROVED' OR "approvedAt" IS NOT NULL);

-- Converted alumni: only ALUMNI, and the data carried over from the Student row must be there
ALTER TABLE "Partner" ADD CONSTRAINT partner_converted_rules CHECK (
  "convertedAt" IS NULL
  OR ("partnerType" = 'ALUMNI' AND "verificationStatus" = 'APPROVED' AND "approvedAt" IS NOT NULL AND "name" IS NOT NULL AND "collegeName" IS NOT NULL
      AND "course" IS NOT NULL AND "graduationYear" IS NOT NULL AND "phone" IS NOT NULL)
);

-- An approved mentor or alumni can be listed or accept requests only when the mentor fields are filled.
-- (a converted alumni starts unlisted with isAcceptingRequests = false until they fill them)
ALTER TABLE "Partner" ADD CONSTRAINT partner_public_mentor_needs_fields CHECK (
  "verificationStatus" <> 'APPROVED' OR "partnerType" NOT IN ('MENTOR_SPEAKER','ALUMNI')
  OR NOT ("isListed" OR "isAcceptingRequests")
  OR ("currentRole" IS NOT NULL AND COALESCE(cardinality("expertise"), 0) > 0 AND "mentorContactEmail" IS NOT NULL)
);

ALTER TABLE "Partner" ADD CONSTRAINT partner_formats CHECK (
  ("website" IS NULL OR "website" ~* '^https://')
  AND ("phone" IS NULL OR "phone" ~ '^\+[1-9][0-9]{7,14}$')
  AND ("alternatePhone" IS NULL OR "alternatePhone" ~ '^\+[1-9][0-9]{7,14}$')
  AND ("alternateEmail" IS NULL OR "alternateEmail" = lower(btrim("alternateEmail")))
  AND ("mentorContactEmail" IS NULL OR "mentorContactEmail" = lower(btrim("mentorContactEmail")))
  AND ("foundingYear" IS NULL OR "foundingYear" BETWEEN 1800 AND 2100)
  AND ("graduationYear" IS NULL OR "graduationYear" BETWEEN 2000 AND 2100)
  AND ("yearsOfExperience" IS NULL OR "yearsOfExperience" BETWEEN 0 AND 60)
);
ALTER TABLE "Partner" ADD CONSTRAINT partner_text_lengths CHECK (
  char_length("name") <= 120 AND char_length("tagline") <= 150 AND char_length("about") <= 3000
  AND char_length("location") <= 150 AND char_length("currentRole") <= 150
  AND char_length("contactPersonName") <= 120 AND char_length("contactPersonDesignation") <= 100
  AND COALESCE(cardinality("expertise"), 0) <= 10 AND max_text_len("expertise") <= 40
);

-- One APPROVED e-cell and one APPROVED college account per college
CREATE UNIQUE INDEX partner_one_approved_entity_per_college ON "Partner" ("partnerType", "collegeCode")
  WHERE "partnerType" IN ('ECELL','COLLEGE') AND "verificationStatus" = 'APPROVED';

-- partnerType never changes; identity fields locked after first approval; no edits while under review
CREATE FUNCTION partner_guard() RETURNS trigger AS $$
BEGIN
  IF NEW."partnerType" IS DISTINCT FROM OLD."partnerType" THEN
    RAISE EXCEPTION 'partnerType never changes';
  END IF;
  IF NEW."convertedAt" IS DISTINCT FROM OLD."convertedAt" THEN
    RAISE EXCEPTION 'convertedAt never changes after the row is created';
  END IF;
  IF OLD."approvedAt" IS NOT NULL AND (
       NEW."name" IS DISTINCT FROM OLD."name"
    OR NEW."collegeCode" IS DISTINCT FROM OLD."collegeCode"
    OR NEW."collegeName" IS DISTINCT FROM OLD."collegeName"
    OR NEW."course" IS DISTINCT FROM OLD."course"
    OR NEW."graduationYear" IS DISTINCT FROM OLD."graduationYear") THEN
    RAISE EXCEPTION 'Partner identity fields are locked after approval';
  END IF;
  IF OLD."verificationStatus" = 'SUBMITTED' AND NEW."verificationStatus" = 'SUBMITTED'
     AND (to_jsonb(NEW) - 'updatedAt') IS DISTINCT FROM (to_jsonb(OLD) - 'updatedAt') THEN
    RAISE EXCEPTION 'Partner is locked while under review';
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER partner_guard_trg BEFORE UPDATE ON "Partner"
  FOR EACH ROW EXECUTE FUNCTION partner_guard();

-- ---------------------------------------------------------------------
-- Startup
-- ---------------------------------------------------------------------

ALTER TABLE "Startup" ADD CONSTRAINT startup_only_for_entrepreneurs CHECK ("partnerType" = 'ENTREPRENEUR');
ALTER TABLE "Startup" ADD CONSTRAINT startup_rules CHECK (
  ("website" IS NULL OR "website" ~* '^https://')
  AND ("foundingYear" IS NULL OR "foundingYear" BETWEEN 1800 AND 2100)
  AND char_length("name") <= 120 AND char_length("description") <= 2000
);

-- ---------------------------------------------------------------------
-- Mentorship Request
-- ---------------------------------------------------------------------

ALTER TABLE "MentorshipRequest" ADD CONSTRAINT mentorship_mentor_type
  CHECK ("mentorType" IN ('MENTOR_SPEAKER','ALUMNI'));
-- exactly one requester (student or alumni), alumni requester must be of type ALUMNI and not the mentor
ALTER TABLE "MentorshipRequest" ADD CONSTRAINT mentorship_one_requester
  CHECK (num_nonnulls("studentId", "requesterAlumniId") = 1
    AND (("requesterAlumniId" IS NULL) = ("requesterAlumniType" IS NULL))
    AND ("requesterAlumniType" IS NULL OR "requesterAlumniType" = 'ALUMNI')
    AND ("requesterAlumniId" IS NULL OR "requesterAlumniId" <> "mentorId"));
ALTER TABLE "MentorshipRequest" ADD CONSTRAINT mentorship_phone_only_when_accepted
  CHECK (NOT "sharePhone" OR "status" = 'ACCEPTED');
ALTER TABLE "MentorshipRequest" ADD CONSTRAINT mentorship_response_has_date
  CHECK ("status" NOT IN ('ACCEPTED','DECLINED') OR "respondedAt" IS NOT NULL);
ALTER TABLE "MentorshipRequest" ADD CONSTRAINT mentorship_text_lengths
  CHECK (char_length("message") <= 1000 AND char_length("responseNote") <= 500);
CREATE UNIQUE INDEX mentorship_one_pending ON "MentorshipRequest" ("studentId", "mentorId")
  WHERE "status" = 'PENDING';
CREATE UNIQUE INDEX mentorship_one_pending_alumni ON "MentorshipRequest" ("requesterAlumniId", "mentorId")
  WHERE "status" = 'PENDING' AND "requesterAlumniId" IS NOT NULL;
CREATE FUNCTION mentorship_expire_stale_pending() RETURNS trigger AS $$
BEGIN
  IF NEW."status" = 'PENDING' THEN
    UPDATE "MentorshipRequest"
       SET "status" = 'EXPIRED', "updatedAt" = timezone('UTC', now())
     WHERE "mentorId" = NEW."mentorId"
       AND "status" = 'PENDING'
       AND "expiresAt" <= timezone('UTC', now())
       AND (("studentId" IS NOT NULL AND "studentId" = NEW."studentId")
         OR ("requesterAlumniId" IS NOT NULL AND "requesterAlumniId" = NEW."requesterAlumniId"));
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER mentorship_expire_stale_pending_trg BEFORE INSERT ON "MentorshipRequest"
  FOR EACH ROW EXECUTE FUNCTION mentorship_expire_stale_pending();  

-- ---------------------------------------------------------------------
-- Collaboration Request
-- ---------------------------------------------------------------------

ALTER TABLE "CollaborationRequest" ADD CONSTRAINT collaboration_response_has_date
  CHECK ("status" NOT IN ('ACCEPTED','DECLINED') OR "respondedAt" IS NOT NULL);
ALTER TABLE "CollaborationRequest" ADD CONSTRAINT collaboration_text_lengths
  CHECK (char_length("title") <= 150 AND char_length("description") <= 3000 AND char_length("responseNote") <= 1000);

-- ---------------------------------------------------------------------
-- Alumni Conversion
-- ---------------------------------------------------------------------

-- Only one batch may run at a time
CREATE UNIQUE INDEX one_running_conversion_batch ON "AlumniConversionBatch" ((true)) WHERE "status" = 'RUNNING';
-- A user can be converted only once
CREATE UNIQUE INDEX alumni_converted_once ON "AlumniConversion" ("userId") WHERE "status" = 'CONVERTED';
-- Conversion history is never edited except by the worker, but never deleted by app code (cascade from User only)
ALTER TABLE "AlumniConversion" ADD CONSTRAINT alumni_conversion_converted_has_date
  CHECK ("status" <> 'CONVERTED' OR "convertedAt" IS NOT NULL);

-- ---------------------------------------------------------------
-- Event
-- ---------------------------------------------------------------
ALTER TABLE "Event"
  ADD CONSTRAINT event_reg_window_chk
    CHECK ("registrationOpensAt" IS NULL OR "registrationClosesAt" IS NULL OR "registrationOpensAt" < "registrationClosesAt"),
  ADD CONSTRAINT event_reg_close_chk
    CHECK ("registrationClosesAt" IS NULL OR "registrationClosesAt" <= "date"),
  ADD CONSTRAINT event_years_chk
    CHECK ("eligibleYears" <@ ARRAY[1,2,3,4,5,6]),
  ADD CONSTRAINT event_media_caps_chk
    CHECK (cardinality("galleryImages") <= 20 AND cardinality("videoLinks") <= 10),
  ADD CONSTRAINT event_team_chk
    CHECK (
      ("participationType" = 'INDIVIDUAL' AND "minTeamSize" IS NULL AND "maxTeamSize" IS NULL)
      OR ("participationType" = 'TEAM' AND "minTeamSize" >= 2 AND "maxTeamSize" >= "minTeamSize" AND "maxTeamSize" <= 10)
    ),
  ADD CONSTRAINT event_fee_chk
    CHECK ("feeAmount" >= 0 AND ("feeAmount" = 0 OR "registrationEnabled")),
  ADD CONSTRAINT event_venue_chk
    CHECK ("mode" = 'ONLINE' OR "venue" IS NOT NULL),
  ADD CONSTRAINT event_published_chk
    CHECK ("status" <> 'PUBLISHED' OR ("poster" IS NOT NULL AND "publishedAt" IS NOT NULL)),
  ADD CONSTRAINT event_cancelled_chk
    CHECK ("status" <> 'CANCELLED' OR "cancelledAt" IS NOT NULL);

-- Lock the terms people registered / paid under, once a live registration exists.
CREATE OR REPLACE FUNCTION event_lock_terms() RETURNS trigger AS $$
BEGIN
  IF (NEW."feeAmount"         IS DISTINCT FROM OLD."feeAmount"
   OR NEW."participationType" IS DISTINCT FROM OLD."participationType"
   OR NEW."minTeamSize"       IS DISTINCT FROM OLD."minTeamSize"
   OR NEW."maxTeamSize"       IS DISTINCT FROM OLD."maxTeamSize"
   OR NEW."eligibleYears"     IS DISTINCT FROM OLD."eligibleYears"
   OR NEW."isRtuOnly"         IS DISTINCT FROM OLD."isRtuOnly")
  AND EXISTS (
    SELECT 1 FROM "EventRegistration" r
    WHERE r."eventId" = OLD."id" AND r."status" IN ('PENDING_PAYMENT', 'CONFIRMED')
  ) THEN
    RAISE EXCEPTION 'Event terms are locked: registrations already exist';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_lock_terms_trg
  BEFORE UPDATE ON "Event"
  FOR EACH ROW EXECUTE FUNCTION event_lock_terms();

-- ---------------------------------------------------------------
-- EventRegistration
-- ---------------------------------------------------------------
ALTER TABLE "EventRegistration"
  ADD CONSTRAINT reg_fee_chk       CHECK ("feeAmount" >= 0),
  ADD CONSTRAINT reg_confirmed_chk CHECK ("status" <> 'CONFIRMED' OR "confirmedAt" IS NOT NULL),
  ADD CONSTRAINT reg_cancelled_chk CHECK ("status" <> 'CANCELLED' OR "cancelledAt" IS NOT NULL);

-- Team name unique per event (case-insensitive) among live registrations
CREATE UNIQUE INDEX reg_team_name_per_event
  ON "EventRegistration" ("eventId", lower("teamName"))
  WHERE "teamName" IS NOT NULL AND "status" IN ('DRAFT', 'PENDING_PAYMENT', 'CONFIRMED');

-- teamName only on TEAM events (required there), never on INDIVIDUAL events
ALTER TABLE "EventRegistration" ADD CONSTRAINT reg_team_name_not_blank
  CHECK ("teamName" IS NULL OR btrim("teamName") <> '');
CREATE FUNCTION event_registration_team_name_guard() RETURNS trigger AS $$
DECLARE p text;
BEGIN
  SELECT "participationType"::text INTO p FROM "Event" WHERE "id" = NEW."eventId";
  IF p = 'INDIVIDUAL' AND NEW."teamName" IS NOT NULL THEN
    RAISE EXCEPTION 'teamName is only allowed on TEAM events';
  END IF;
  IF p = 'TEAM' AND NEW."teamName" IS NULL THEN
    RAISE EXCEPTION 'teamName is required on TEAM events';
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER event_registration_team_name_guard_trg
  BEFORE INSERT OR UPDATE OF "teamName", "eventId" ON "EventRegistration"
  FOR EACH ROW EXECUTE FUNCTION event_registration_team_name_guard();

-- ---------------------------------------------------------------
-- EventRegistrationMember
-- ---------------------------------------------------------------
-- A student can be in only ONE live registration per event
CREATE UNIQUE INDEX member_one_live_per_event
  ON "EventRegistrationMember" ("eventId", "studentId")
  WHERE "leftAt" IS NULL;

-- At most one live leader per registration
CREATE UNIQUE INDEX member_one_live_leader
  ON "EventRegistrationMember" ("registrationId")
  WHERE "isLeader" AND "leftAt" IS NULL;

-- ---------------------------------------------------------------
-- EventTeamInvite
-- ---------------------------------------------------------------
ALTER TABLE "EventTeamInvite"
  ADD CONSTRAINT invite_responded_chk
    CHECK (("status" = 'PENDING' AND "respondedAt" IS NULL) OR ("status" <> 'PENDING' AND "respondedAt" IS NOT NULL));
-- Keeps respondedAt in step with status: re-inviting (back to PENDING) clears it, any other status sets it.
CREATE FUNCTION invite_responded_at_sync() RETURNS trigger AS $$
BEGIN
  IF NEW."status" = 'PENDING' THEN
    NEW."respondedAt" := NULL;
  ELSIF NEW."respondedAt" IS NULL THEN
    NEW."respondedAt" := timezone('UTC', now());
  END IF;
  RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER invite_responded_at_sync_trg BEFORE INSERT OR UPDATE ON "EventTeamInvite"
  FOR EACH ROW EXECUTE FUNCTION invite_responded_at_sync();

-- ---------------------------------------------------------------
-- Payment
-- ---------------------------------------------------------------
ALTER TABLE "Payment"
  ADD CONSTRAINT payment_amount_chk CHECK ("amount" > 0),
  ADD CONSTRAINT payment_refund_chk CHECK ("refundedAmount" >= 0 AND "refundedAmount" <= "amount"),
  ADD CONSTRAINT payment_paid_chk   CHECK ("status" NOT IN ('PAID', 'REFUND_PENDING', 'REFUNDED') OR ("paidAt" IS NOT NULL AND "gatewayPaymentId" IS NOT NULL));

-- A registration can have many attempts but only ONE successful payment
CREATE UNIQUE INDEX payment_one_paid_per_registration
  ON "Payment" ("registrationId")
  WHERE "status" = 'PAID';


-- ---------------------------------------------------------------------
-- EXTERNAL OPPORTUNITIES 
-- ---------------------------------------------------------------------
-- Table/column names are Prisma defaults (quoted camelCase).

ALTER TABLE "ExternalOpportunity"
  -- text lengths, and no blank-only strings
  ADD CONSTRAINT extopp_title_chk
    CHECK (btrim("title") <> '' AND char_length("title") <= 150),
  ADD CONSTRAINT extopp_organizer_chk
    CHECK (btrim("organizerName") <> '' AND char_length("organizerName") <= 100),
  ADD CONSTRAINT extopp_desc_chk
    CHECK (btrim("shortDescription") <> '' AND char_length("shortDescription") <= 300),

  -- https only, no whitespace, max 500 chars
  ADD CONSTRAINT extopp_link_chk
    CHECK ("applyLink" ~* '^https://[^[:space:]]+$' AND char_length("applyLink") <= 500),

  -- location is required unless the opportunity is fully remote
  ADD CONSTRAINT extopp_location_chk
    CHECK (
      ("mode" = 'REMOTE' OR ("location" IS NOT NULL AND btrim("location") <> ''))
      AND ("location" IS NULL OR char_length("location") <= 100)
    ),

  -- year of study 1..6, empty array = all years
  ADD CONSTRAINT extopp_years_chk
    CHECK ("eligibleYears" <@ ARRAY[1,2,3,4,5,6]),

  ADD CONSTRAINT extopp_clicks_chk
    CHECK ("clickCount" >= 0),

  -- a published row must say when it was published
  ADD CONSTRAINT extopp_published_chk
    CHECK ("status" <> 'PUBLISHED' OR "publishedAt" IS NOT NULL);

-- Duplicate guard: scheme+host compared case-insensitively, path compared exactly (paths are case-sensitive).
CREATE UNIQUE INDEX extopp_apply_link_host_lower_uq ON "ExternalOpportunity" (
  (lower(substring("applyLink" from '^https://[^/?#]*')) || substring("applyLink" from '^https://[^/?#]*(.*)$'))
);

-- ---------------------------------------------------------------------
-- (Innovation + Incubation)
-- ---------------------------------------------------------------------

-- Every element is a non-empty trimmed string of at most max_len chars, and the array has at most max_items elements.
CREATE OR REPLACE FUNCTION initiative_text_array_ok(arr text[], max_items int, max_len int)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $$
  SELECT cardinality(arr) <= max_items
     AND COALESCE((SELECT bool_and(char_length(btrim(e)) BETWEEN 1 AND max_len) FROM unnest(arr) AS e), true)
$$;

-- Every element is an https link of at most 500 chars without whitespace, and the array has at most max_items elements.
CREATE OR REPLACE FUNCTION initiative_https_array_ok(arr text[], max_items int)
RETURNS boolean LANGUAGE sql IMMUTABLE AS $$
  SELECT cardinality(arr) <= max_items
     AND COALESCE((SELECT bool_and(e ~* '^https://[^[:space:]]+$' AND char_length(e) <= 500) FROM unnest(arr) AS e), true)
$$;

-- ---------------------------------------------------------------------
-- EVENT (extra constraints; needs the initiative_* helpers above)
-- ---------------------------------------------------------------------
ALTER TABLE "Event"
  ADD CONSTRAINT event_slug_format_chk
    CHECK ("slug" ~ '^[a-z0-9]+(-[a-z0-9]+)*$' AND char_length("slug") <= 120),
  ADD CONSTRAINT event_title_len_chk
    CHECK (char_length(btrim("title")) BETWEEN 1 AND 150),
  ADD CONSTRAINT event_summary_len_chk
    CHECK ("summary" IS NULL OR char_length("summary") <= 200),
  ADD CONSTRAINT event_description_len_chk
    CHECK (char_length("description") <= 20000),
  ADD CONSTRAINT event_galleryImages_chk
    CHECK (initiative_text_array_ok("galleryImages", 20, 300)),
  ADD CONSTRAINT event_videoLinks_chk
    CHECK (initiative_https_array_ok("videoLinks", 10)),
  ADD CONSTRAINT event_onlineLink_chk
    CHECK ("onlineLink" IS NULL OR ("onlineLink" ~* '^https://[^[:space:]]+$' AND char_length("onlineLink") <= 500));

-- slug never changes once the event has been published
CREATE FUNCTION event_lock_slug() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF OLD."publishedAt" IS NOT NULL AND NEW."slug" IS DISTINCT FROM OLD."slug" THEN
    RAISE EXCEPTION 'Event slug cannot change after the first publish';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER event_lock_slug_trg
  BEFORE UPDATE OF "slug" ON "Event"
  FOR EACH ROW EXECUTE FUNCTION event_lock_slug();

-- ---------------------------------------------------------------------
-- INNOVATION
-- ---------------------------------------------------------------------

ALTER TABLE "Innovation"
  ADD CONSTRAINT "Innovation_slug_format_chk"
    CHECK ("slug" ~ '^[a-z0-9]+(-[a-z0-9]+)*$' AND char_length("slug") <= 120),
  ADD CONSTRAINT "Innovation_title_len_chk"
    CHECK (char_length(btrim("title")) BETWEEN 1 AND 150),
  ADD CONSTRAINT "Innovation_shortDescription_len_chk"
    CHECK (char_length(btrim("shortDescription")) BETWEEN 1 AND 200),
  ADD CONSTRAINT "Innovation_thumbnail_len_chk"
    CHECK ("thumbnail" IS NULL OR char_length(btrim("thumbnail")) BETWEEN 1 AND 300),
  ADD CONSTRAINT "Innovation_description_len_chk"
    CHECK ("description" IS NULL OR char_length("description") <= 20000),
  -- a detail page needs content. The reverse is allowed on purpose (hidden content survives turning the flag off)
  ADD CONSTRAINT "Innovation_detailpage_needs_description_chk"
    CHECK (NOT "hasDetailPage" OR ("description" IS NOT NULL AND char_length(btrim("description")) > 0)),
  ADD CONSTRAINT "Innovation_galleryImages_chk"
    CHECK (initiative_text_array_ok("galleryImages", 20, 300)),
  ADD CONSTRAINT "Innovation_videoLinks_chk"
    CHECK (initiative_https_array_ok("videoLinks", 10)),
  ADD CONSTRAINT "Innovation_members_chk"
    CHECK (initiative_text_array_ok("members", 10, 80)),
  ADD CONSTRAINT "Innovation_year_chk"
    CHECK ("year" BETWEEN 2000 AND 2100), -- "not in the future" is checked in the API (now() is not allowed in a CHECK)
  ADD CONSTRAINT "Innovation_demoUrl_chk"
    CHECK ("demoUrl" IS NULL OR ("demoUrl" ~* '^https://[^[:space:]]+$' AND char_length("demoUrl") <= 500)),
  ADD CONSTRAINT "Innovation_displayOrder_chk"
    CHECK ("displayOrder" >= 0),
  ADD CONSTRAINT "Innovation_published_complete_chk"
    CHECK ("status" <> 'PUBLISHED'
           OR ("publishedAt" IS NOT NULL AND "thumbnail" IS NOT NULL AND cardinality("members") >= 1));

-- slug never changes once the innovation has been published (publishedAt stays set even if it is moved back to DRAFT)
CREATE OR REPLACE FUNCTION innovation_lock_slug() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF OLD."publishedAt" IS NOT NULL AND NEW."slug" IS DISTINCT FROM OLD."slug" THEN
    RAISE EXCEPTION 'Innovation slug cannot change after the first publish';
  END IF;
  RETURN NEW;
END $$;

CREATE TRIGGER "Innovation_lock_slug"
  BEFORE UPDATE OF "slug" ON "Innovation"
  FOR EACH ROW EXECUTE FUNCTION innovation_lock_slug();

-- ---------------------------------------------------------------------
-- INCUBATION
-- ---------------------------------------------------------------------

ALTER TABLE "Incubation"
  ADD CONSTRAINT "Incubation_title_len_chk"
    CHECK (char_length(btrim("title")) BETWEEN 1 AND 150),
  ADD CONSTRAINT "Incubation_shortDescription_len_chk"
    CHECK (char_length(btrim("shortDescription")) BETWEEN 1 AND 200),
  ADD CONSTRAINT "Incubation_logo_len_chk"
    CHECK ("logo" IS NULL OR char_length(btrim("logo")) BETWEEN 1 AND 300),
  ADD CONSTRAINT "Incubation_website_chk"
    CHECK ("website" IS NULL OR ("website" ~* '^https://[^[:space:]]+$' AND char_length("website") <= 500)),
  ADD CONSTRAINT "Incubation_founders_chk"
    CHECK (initiative_text_array_ok("founders", 10, 80)),
  ADD CONSTRAINT "Incubation_incubatedYear_chk"
    CHECK ("incubatedYear" BETWEEN 2000 AND 2100), -- "not in the future" is checked in the API
  ADD CONSTRAINT "Incubation_displayOrder_chk"
    CHECK ("displayOrder" >= 0),
  ADD CONSTRAINT "Incubation_published_complete_chk"
    CHECK ("status" <> 'PUBLISHED'
           OR ("publishedAt" IS NOT NULL AND "logo" IS NOT NULL AND cardinality("founders") >= 1));

-- case-insensitive duplicate guard (Prisma's @unique on title only catches exact matches)
CREATE UNIQUE INDEX "Incubation_title_lower_key" ON "Incubation" (lower(btrim("title")));
