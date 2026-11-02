// A small JSON Schema subset validator, so tool scripts stay zero-dependency.
// Supports: type, enum, const, required, properties, additionalProperties (false | schema),
// items, minItems, minLength, pattern, minimum, maximum, and $ref to "#/$defs/<name>".

const typeOf = (v) => {
  if (v === null) return 'null';
  if (Array.isArray(v)) return 'array';
  if (Number.isInteger(v)) return 'integer';
  return typeof v;
};

const typeMatches = (want, v) => {
  const got = typeOf(v);
  return want === got || (want === 'number' && got === 'integer');
};

export function validate(schema, value, root = schema, path = '$') {
  if (schema.$ref) {
    const name = schema.$ref.replace('#/$defs/', '');
    return validate(root.$defs[name], value, root, path);
  }
  const errors = [];
  const fail = (msg) => errors.push(`${path}: ${msg}`);
  if (schema.type) {
    const wants = [].concat(schema.type);
    if (!wants.some((w) => typeMatches(w, value))) {
      fail(`expected ${wants.join('|')}, got ${typeOf(value)}`);
      return errors;
    }
  }
  if (schema.const !== undefined && value !== schema.const) fail(`must equal ${schema.const}`);
  if (schema.enum && !schema.enum.includes(value)) fail(`must be one of ${schema.enum.join(', ')}`);
  if (typeof value === 'string') {
    if (schema.minLength && value.length < schema.minLength) fail('too short');
    if (schema.pattern && !new RegExp(schema.pattern).test(value)) {
      fail(`must match ${schema.pattern}`);
    }
  }
  if (typeof value === 'number') {
    if (schema.minimum !== undefined && value < schema.minimum) fail(`must be >= ${schema.minimum}`);
    if (schema.maximum !== undefined && value > schema.maximum) fail(`must be <= ${schema.maximum}`);
  }
  if (Array.isArray(value)) {
    if (schema.minItems && value.length < schema.minItems) fail(`needs >= ${schema.minItems} items`);
    if (schema.items) {
      value.forEach((item, i) => errors.push(...validate(schema.items, item, root, `${path}[${i}]`)));
    }
  }
  if (typeOf(value) === 'object') errors.push(...validateObject(schema, value, root, path));
  return errors;
}

function validateObject(schema, value, root, path) {
  const errors = [];
  for (const key of schema.required ?? []) {
    if (!(key in value)) errors.push(`${path}: missing required "${key}"`);
  }
  const props = schema.properties ?? {};
  for (const [key, child] of Object.entries(value)) {
    if (props[key]) {
      errors.push(...validate(props[key], child, root, `${path}.${key}`));
    } else if (schema.additionalProperties === false) {
      errors.push(`${path}: unknown key "${key}"`);
    } else if (typeof schema.additionalProperties === 'object') {
      errors.push(...validate(schema.additionalProperties, child, root, `${path}.${key}`));
    }
  }
  return errors;
}
