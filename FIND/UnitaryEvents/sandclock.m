function sandclock(mode,steps)


switch mode
 case 'create'
  sp=get(0,'ScreenSize');
  f=figure(...
     'Units', 'pixels', ...
     'Position',[sp(3)-300-20 20 300 100], ...
     'Color',[0.87 0.87 0.89], ...
     'MenuBar', 'none', ...
     'Resize', 'off', ...
     'Name', 'SandClock', ...
     'NumberTitle', 'off', ...
     'Tag', 'SandClock' ...
    );
  a=axes(...
     'Units', 'pixels', ...
     'XLim', [0 steps], ...
     'YLim', [0 1], ...
     'Box', 'on', ...
     'XTick', [], ...
     'YTick', [], ...
     'Position', [50 20 200 40], ...
     'Tag', 'SandClockAxis' ...
  );
  p=patch(...
     'XData',[0 0 0 0 0], ...
     'YData',[0 0 1 1 0], ...
     'FaceColor',[1 0 0], ...
     'Tag', 'SandClockBar' ...
    );
  text(...
      'String', 'Moving Window Analysis', ...
      'HorizontalAlignment', 'center', ...
      'FontWeight', 'bold', ...
      'FontSize', 14, ...
      'Position', [steps/2, 1.5] ...
     );

 case 'set'
  p=findobj('Tag','SandClockBar');
  set(p, ...
      'XData',[0 steps steps 0 0], ...
      'YData',[0 0 1 1 0] ...
     );
  drawnow;
 case 'close'
  f=findobj('Tag','SandClock');
  close(f); 
 otherwise
  error('SandClock::UnknownMode');
end