-- ============================================================
-- ADMIN RLS POLICIES FOR EVENTORIA
-- ============================================================
-- Run the following statements in the Supabase SQL Editor to
-- allow authenticated Admins to view and control all resources.
-- ============================================================

-- 1. PROFILES TABLE POLICIES
CREATE POLICY "Admins can view all profiles"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can update any profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  )
  WITH CHECK (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can delete any profile"
  ON public.profiles
  FOR DELETE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );


-- 2. EVENTS TABLE POLICIES
CREATE POLICY "Admins can view all events"
  ON public.events
  FOR SELECT
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can update any event"
  ON public.events
  FOR UPDATE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  )
  WITH CHECK (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can delete any event"
  ON public.events
  FOR DELETE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );


-- 3. TICKETS TABLE POLICIES
CREATE POLICY "Admins can view all tickets"
  ON public.tickets
  FOR SELECT
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can update any ticket"
  ON public.tickets
  FOR UPDATE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  )
  WITH CHECK (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can delete any ticket"
  ON public.tickets
  FOR DELETE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );


-- 4. TICKET TIERS TABLE POLICIES
CREATE POLICY "Admins can view all ticket_tiers"
  ON public.ticket_tiers
  FOR SELECT
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can update any ticket_tier"
  ON public.ticket_tiers
  FOR UPDATE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  )
  WITH CHECK (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );

CREATE POLICY "Admins can delete any ticket_tier"
  ON public.ticket_tiers
  FOR DELETE
  TO authenticated
  USING (
    ((auth.jwt() -> 'user_metadata') ->> 'role') = 'admin'
  );
