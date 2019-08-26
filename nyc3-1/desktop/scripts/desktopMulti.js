module.exports = async function(context, commands) {
  await commands.measure.start('https://en.wikipedia.org/wiki/Main_Page');
  await commands.js.run(
    'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
  );
  await commands.measure.start('https://en.wikipedia.org/wiki/Barack_Obama');
  await commands.js.run(
    'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
  );
  return commands.measure.start(
    'https://en.wikipedia.org/wiki/Democratic_Party_(United_States)'
  );
};
