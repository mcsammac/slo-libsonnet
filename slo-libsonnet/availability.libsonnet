local util = import '_util.libsonnet';
{
    availability(param):: {
     local slo = {
       metric: error 'must set metric for errors',
       selectors: [],
       errorSelectors: ['code!~"5.."'],
       rate: '5m',
       labels: [],
      } + param,
    
    local labels = 
      util.selectorsToLabels(slo.selectors) + 
      util.selectorsToLabels(slo.labels),
    recordingrule: {
        expr: |||
          sum(rate(%(metric)s{%(errorSelectors)s}[%(rate)s]))
          /
          sum(rate(%(metric)s{%(selectors)s}[%(rate)s]))
        ||| % {
          metric: slo.metric,
          selectors: std.join(',', slo.selectors),
          errorSelectors: std.join(',', slo.selectors + slo.errorSelectors),
        },
        record: '%s:availability' % slo.rate,
        labels: labels,
      }
    }
}