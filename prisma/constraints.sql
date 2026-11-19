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
