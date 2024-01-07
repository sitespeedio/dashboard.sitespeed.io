/**
 * @param {import('browsertime').BrowsertimeContext} context
 * @param {import('browsertime').BrowsertimeCommands} commands
 */
export default async function(context, commands) {
  // We start by navigating to the login page.
  await commands.measure.start(
    'https://en.wikipedia.org/w/index.php?title=Special:UserLogin&returnto=Main+Page',
    'LoginPage'
  );

  // When we fill in a input field/click on a link we wanna
  // try/catch that if the HTML on the page changes in the feature
  // sitespeed.io will automatically log the error in a user friendly
  // way, and the error will be re-thrown so you can act on it.
  try {
    // Add text into an input field, finding the field by id
    const userName = context.options.wikipedia.user;
    const password = context.options.wikipedia.password;

    await commands.addText.byId(userName, 'wpName1');
    await commands.addText.byId(password, 'wpPassword1');

    // Start the measurement before we click on the
    // submit button. Sitespeed.io will start the video recording
    // and prepare everything.
    // But first we hide all elements to avoid a too early first visual change
    // caused by the submit button.
    await commands.js.run(
      'for (let node of document.body.childNodes) { if (node.style) node.style.display = "none";}'
    );
    await commands.measure.start('LoggedIn');
    // Find the sumbit button and click it and then wait
    // for the pageCompleteCheck to finish
    await commands.click.byIdAndWait('wpLoginAttempt');
    // Stop and collect the measurement before the next page we want to measure
    await commands.measure.stop();
    await commands.wait.byTime(21000);
    await commands.js.run(
      'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
    );
    // Measure the Barack Obama page as a logged in user
    await commands.measure.start('https://en.wikipedia.org/wiki/Barack_Obama');
    await commands.wait.byTime(21000);
    await commands.js.run(
      'document.body.innerHTML = ""; document.body.style.backgroundColor = "white";'
    );
    // And then measure the president page
    return commands.measure.start(
      'https://en.wikipedia.org/wiki/President_of_the_United_States'
    );
  } catch (e) {
    context.log.error(e);
    // We try/catch so we will catch if the the input fields can't be found
    // The error is automatically logged in Browsertime and re-thrown here
  }
}
