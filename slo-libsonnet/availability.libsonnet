local util = import '_util.libsonnet';
{
    availability(param):: {
     local slo = {
       metric: error 'must set metric for errors',
       selectors: [],
       nonErrorSelectors: ['code!~"5.."'],
       rate: '5m',
       labels: [],
      } + param,
    
    local labels = 
      util.selectorsToLabels(slo.selectors) + 
      util.selectorsToLabels(slo.labels),
    recordingrule():: {
        expr: |||
          sum(rate(%(metric)s{%(nonErrorSelectors)s}[5m]))
          /
          sum(rate(%(metric)s{%(selectors)s}[5m]))
        ||| % {
          metric: slo.metric,
          selectors: std.join(',', slo.selectors),
          errorSelectors: std.join(',', slo.selectors + slo.errorSelectors),
        },
        record: '%s:availability',
        labels: labels,
      }
    }
}