-- Script para corregir RLS

-- ================================
-- CORRECCIÓN DE RECURSIÓN RLS
-- ================================

-- Desactivar RLS temporalmente para hacer cambios
SET row_security = off;

-- Eliminar todas las políticas existentes que causan recursión
DROP POLICY IF EXISTS "Users can view their own organization" ON organizations;
DROP POLICY IF EXISTS "Users can view users in their organization" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Owners can create technicians" ON users;
DROP POLICY IF EXISTS "Organization data isolation" ON customers;
DROP POLICY IF EXISTS "Organization data isolation" ON devices;
DROP POLICY IF EXISTS "Organization data isolation" ON repairs;
DROP POLICY IF EXISTS "Organization data isolation" ON inventory;
DROP POLICY IF EXISTS "Organization data isolation" ON repair_parts;
DROP POLICY IF EXISTS "Organization data isolation" ON inventory_movements;
DROP POLICY IF EXISTS "Organization data isolation" ON sales;
DROP POLICY IF EXISTS "Organization data isolation" ON sale_items;
DROP POLICY IF EXISTS "Organization data isolation" ON unlocks;
DROP POLICY IF EXISTS "Organization data isolation" ON organization_settings;

-- Crear función auxiliar para obtener organization_id sin recursión
CREATE OR REPLACE FUNCTION get_user_organization_id(user_auth_id UUID)
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT organization_id FROM users WHERE auth_user_id = user_auth_id LIMIT 1;
$$;

-- Crear políticas corregidas usando la función auxiliar

-- Política para organizaciones
CREATE POLICY "Users can view their own organization" ON organizations
    FOR SELECT USING (
        id = get_user_organization_id(auth.uid())
    );

-- Políticas para usuarios
CREATE POLICY "Users can view users in their organization" ON users
    FOR SELECT USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth_user_id = auth.uid());

CREATE POLICY "Owners can create technicians" ON users
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_user_id = auth.uid()
            AND u.role = 'owner'
            AND u.organization_id = organization_id
        )
        AND role IN ('technician', 'owner')
    );

-- Políticas para todas las tablas con organization_id usando la función auxiliar
CREATE POLICY "Organization data isolation" ON customers
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON devices
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON repairs
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON inventory
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON repair_parts
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON inventory_movements
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON sales
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON sale_items
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON unlocks
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

CREATE POLICY "Organization data isolation" ON organization_settings
    FOR ALL USING (
        organization_id = get_user_organization_id(auth.uid())
    );

-- Reactivar RLS
SET row_security = on;
