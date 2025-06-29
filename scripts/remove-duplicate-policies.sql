-- Eliminar politicas duplicadas
-- Ejecutar este script para limpiar políticas RLS duplicadas

-- Deshabilitar RLS temporalmente
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE devices DISABLE ROW LEVEL SECURITY;
ALTER TABLE repairs DISABLE ROW LEVEL SECURITY;
ALTER TABLE inventory DISABLE ROW LEVEL SECURITY;
ALTER TABLE sales DISABLE ROW LEVEL SECURITY;
ALTER TABLE unlocks DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE organizations DISABLE ROW LEVEL SECURITY;

-- Eliminar todas las políticas duplicadas
DROP POLICY IF EXISTS "Organization data isolation" ON customers;
DROP POLICY IF EXISTS "Organization data isolation" ON devices;
DROP POLICY IF EXISTS "Organization data isolation" ON repairs;
DROP POLICY IF EXISTS "Organization data isolation" ON inventory;
DROP POLICY IF EXISTS "Organization data isolation" ON sales;
DROP POLICY IF EXISTS "Organization data isolation" ON unlocks;
DROP POLICY IF EXISTS "Users can view their own organization" ON organizations;
DROP POLICY IF EXISTS "Users can view users in their organization" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Owners can create technicians" ON users;

-- Mensaje de confirmación
SELECT 'Políticas RLS eliminadas exitosamente. Sistema listo para uso sin RLS.' as status;