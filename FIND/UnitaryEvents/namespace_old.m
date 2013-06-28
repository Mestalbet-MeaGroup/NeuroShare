function namespace(name)
% namespace(name), define members of struct name in caller's workspace
% ***************************************************************
% *                                                             *
% * Usage:                                                      *
% *       namespace() is typically called with a struct name    *
% *       declared global in the caller's workspace.            *
% *       namespace() defines all members of struct name in the *
% *       the caller's workspace.                               *
% *       namespace() displays a warning if it is overriding    *
% *       an already defined variable.                          *
% *                                                             *
% * Example:                                                    *
% *         Let x with x.y==5 be a global struct.               *
% *         function f                                          *
% *          global x; namespace(x);                            *
% *          disp(y);                                           *
% *         a matlab function.                                  *
% *         A call to f will print 5.                           *
% *                                                             * 
% * Future:                                                     *
% *         write the reverse function endnamespace(name)       *
% *                                                             *
% * Uses:                                                       *
% *       - evalin   (matlab5)                                  *
% *       - assignin (matlab5)                                  *
% *       - warining (matlab5)                                  *
% *		                                                *
% * History:							*
% *         (0) first version                                   *
% *            MD, 3.8.1997                                     * 
% *                                                             *
% *                                                             *
% *                          diesmann@biologie.uni-freiburg.de  *
% *                          gruen@hbf.huji.ac.il               *
% *                                                             *
% ***************************************************************
fname=fieldnames(name);

for i=1:size(fname,1)
 shadowing=1;
 evalin('caller',cat(2,fname{i},';'),'shadowing=0;');
 if shadowing
  warning('NameSpace::OverridingName')
 end
 assignin('caller',fname{i},getfield(name,fname{i}));
end