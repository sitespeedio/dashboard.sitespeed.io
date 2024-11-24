/**
 * @param {import('browsertime').BrowsertimeContext} context
 * @param {import('browsertime').BrowsertimeCommands} commands
 */
export default async function(context, commands) {
  commands.meta.setTitle('Test Grafana SPA');
  commands.meta.setDescription(
    'Test the first page, click the timepicker and then choose <b>Last 30 days</b> and measure that page.'
  );
  await commands.measure.start(
    'https://dashboard.sitespeed.io/d/9NDMzFfMk/page-metrics-desktop?orgId=1&var-base=sitespeed_io&var-path=desktop&var-testname=spa&var-group=dashboard_sitespeed_io&var-page=pageTimingMetricsDefault&var-browser=chrome&var-connectivity=cable&var-function=median&var-resulturl=https:%2F%2Fdata.sitespeed.io%2F&var-screenshottype=jpg',
    'pageTimingMetricsDefault'
  );
  await commands.click.byClassName('css-16us58v-toolbar-button');
  await commands.wait.byTime(3000);
  await commands.measure.start('pageTimingMetrics30Days');
  try {
    await commands.click.byXpathAndWait(
      '/html/body/div/div/div[1]/div/div/main/div[3]/div/div/div[1]/div/div[2]/div[1]/div/section/div/div[1]/div[1]/div[2]/ul/li[11]/label'
    );
    await commands.wait.byTime(5000);
  } catch (error) {
    context.log.error('Could not find Grafanas 30 days dropdown');
    throw error;
  }

  return commands.measure.stop();
}
