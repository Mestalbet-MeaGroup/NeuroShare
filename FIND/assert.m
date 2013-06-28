function a = assert(inexpr, not_response, varargin);
% ASSERT - test if control conditions are met
% ASSERT(inexpr, not_response) is used to test if the conditon 
% <inexpr> (string) is met in the calling workspace. ASSERT 
% executes <not_response> if the control fails. <not_response>
% is also a string that can be either 'error', 'warning', 
% 'break', 'keyboard', 'disp', or 'pause' which will issue an 
% appropriate message and then call the respective matlab 
% command. 'disp' will show the result of the control statement.
%
% ASSERT with one input argument only is equal to not_response = 'error'.
%
% U. Egert 11/97

space = 'caller';
pvpmod(varargin);

callfile = evalin('caller', 'mfilename');

eval('isstr(not_response);', 'not_response = ''error'' ;');

a= evalin(space,  inexpr, '1 == 0');

if a == 0
   switch not_response
   case {'error', 'warning'}
      error([callfile ':: control condition ' inexpr ' was not met'])
   case 'break'
      disp([callfile ':: control condition ' inexpr ' was not met, breaking'])
      return
   case 'keyboard'
      disp([callfile ':: control condition ' inexpr ' was not met, control handed to keyboard'])
      keyboard
   case 'pause'
      disp([callfile ':: control condition ' inexpr ' was not met, pausing'])
      pause
   case 'disp'
      disp([callfile ':: control condition ' inexpr ' was not met'])
      disp('result of control expression: ') 
      evalin(space,  inexpr)
   case 'return'
      evalin(space, 'return');
   case 'nothing'
      disp([callfile ':: control condition ' inexpr ' was not met'])
   otherwise
      error([callfile ':: control condition ' inexpr ' was not met'])
   end;
end;


