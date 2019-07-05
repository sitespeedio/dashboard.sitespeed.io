module.exports = async function(context, commands) {
  await commands.measure.start('https://en.wikipedia.org/wiki/Main_Page');
  await commands.measure.start('https://en.wikipedia.org/wiki/Barack_Obama');
  return commands.measure.start(
    'https://en.wikipedia.org/wiki/Democratic_Party_(United_States)'
  );
};
