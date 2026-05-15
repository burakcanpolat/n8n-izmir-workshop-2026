import { describe, it, expect } from 'vitest';
import { isReadOnly } from '../src/security';

describe('isReadOnly', () => {
  it('accepts a simple SELECT', () => {
    expect(isReadOnly('SELECT * FROM Artist')).toBeNull();
  });

  it('accepts SELECT with leading whitespace and trailing semicolon', () => {
    expect(isReadOnly('   SELECT 1 ;  ')).toBeNull();
  });

  it('accepts WITH ... SELECT (CTE)', () => {
    expect(isReadOnly('WITH x AS (SELECT 1) SELECT * FROM x')).toBeNull();
  });

  it('accepts mixed-case SELECT', () => {
    expect(isReadOnly('select count(*) from Track')).toBeNull();
  });

  it('rejects INSERT', () => {
    expect(isReadOnly("INSERT INTO Artist (Name) VALUES ('x')")).toMatch(/SELECT/i);
  });

  it('rejects UPDATE', () => {
    expect(isReadOnly("UPDATE Artist SET Name='x' WHERE ArtistId=1")).toMatch(/SELECT/i);
  });

  it('rejects DELETE', () => {
    expect(isReadOnly('DELETE FROM Artist WHERE ArtistId=1')).toMatch(/SELECT/i);
  });

  it('rejects DROP', () => {
    expect(isReadOnly('DROP TABLE Artist')).toMatch(/SELECT/i);
  });

  it('rejects ALTER', () => {
    expect(isReadOnly('ALTER TABLE Artist ADD COLUMN x TEXT')).toMatch(/SELECT/i);
  });

  it('rejects CREATE', () => {
    expect(isReadOnly('CREATE TABLE Evil (x INT)')).toMatch(/SELECT/i);
  });

  it('rejects PRAGMA', () => {
    expect(isReadOnly('PRAGMA writable_schema = 1')).toMatch(/SELECT/i);
  });

  it('rejects mixed statement (SELECT then DROP)', () => {
    expect(isReadOnly('SELECT 1; DROP TABLE Artist')).toMatch(/SELECT/i);
  });

  it('rejects oversize query (>4000 chars)', () => {
    const longSql = 'SELECT * FROM Artist WHERE Name IN (' + Array(2000).fill("'x'").join(',') + ')';
    expect(longSql.length).toBeGreaterThan(4000);
    expect(isReadOnly(longSql)).toMatch(/4000/);
  });

  it('rejects empty string', () => {
    expect(isReadOnly('')).toMatch(/SELECT/i);
  });

  it('rejects bare comment that looks like SELECT', () => {
    expect(isReadOnly('-- SELECT * FROM Artist')).toMatch(/SELECT/i);
  });
});
