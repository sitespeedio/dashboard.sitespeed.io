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
  await commands.click.byXpath(
    '//button[@data-testid="data-testid TimePicker Open Button"]'
  );
  await commands.wait.bySelector(
    '[data-testid="data-testid TimePicker Overlay Content"]',
    10000
  );
  await commands.measure.start('pageTimingMetrics30Days');
  try {
    await commands.click.byXpath(
      '//li[label[normalize-space(.)="Last 30 days"]]/input'
    );
    await commands.wait.byCondition(
      'window.location.href.includes("from=now-30d")',
      10000
    );
    await commands.wait.byTime(5000);
  } catch (error) {
    context.log.error('Could not select Grafanas Last 30 days range');
    throw error;
  }

  return commands.measure.stop();
}
