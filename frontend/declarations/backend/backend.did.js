export const idlFactory = ({ IDL }) => {
  const Result_1 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'accessJSONPath' : IDL.Func([IDL.Text], [Result_1], ['query']),
    'getJSON' : IDL.Func([], [IDL.Text], ['query']),
    'setJSON' : IDL.Func([IDL.Text], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };
