-- ============================================================
-- FIX 1: Allow organizers to read tickets for their own events
-- ============================================================
-- Run BOTH policies below in Supabase SQL Editor.
-- ============================================================

-- Policy 1 — tickets table
-- Allows an organizer to SELECT all tickets for events they own.
CREATE POLICY "organizers_can_view_event_tickets"
  ON public.tickets
  FOR SELECT
  TO authenticated
  USING (
    event_id IN (
      SELECT id
      FROM public.events
      WHERE organizer_id = auth.uid()
    )
  );

-- ============================================================
-- FIX 2: Allow organizers to read attendee profiles
-- ============================================================
-- The `profiles` table also has RLS. Without this policy the
-- embedded join `profiles(full_name, email, ...)` returns null,
-- which causes "Unknown Attendee" / "No email" in the UI.
-- ============================================================

-- Policy 2 — profiles table
-- Allows an organizer to SELECT the profiles of users who have
-- bought a ticket to any of the organizer's events.
CREATE POLICY "organizers_can_view_attendee_profiles"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT t.attendee_id
      FROM public.tickets t
      JOIN public.events e ON t.event_id = e.id
      WHERE e.organizer_id = auth.uid()
    )
  );

-- ============================================================
-- OPTIONAL: Allow organizers to check tickets in
-- (UPDATE is_checked_in). Uncomment if needed.
-- ============================================================
-- CREATE POLICY "organizers_can_check_in_tickets"
--   ON public.tickets
--   FOR UPDATE
--   TO authenticated
--   USING (
--     event_id IN (
--       SELECT id FROM public.events WHERE organizer_id = auth.uid()
--     )
--   )
--   WITH CHECK (
--     event_id IN (
--       SELECT id FROM public.events WHERE organizer_id = auth.uid()
--     )
--   );

--       SELECT id FROM public.events WHERE organizer_id = auth.uid()
--     )
--   );
