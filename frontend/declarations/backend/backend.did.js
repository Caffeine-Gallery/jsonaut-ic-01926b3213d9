export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'accessJSONPath' : IDL.Func([IDL.Text], [IDL.Text], ['query']),
    'getJSON' : IDL.Func([], [IDL.Text], ['query']),
    'setJSON' : IDL.Func([IDL.Text], [], []),
  });
};
export const init = ({ IDL }) => { return []; };
