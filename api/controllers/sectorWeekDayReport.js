module.exports = function (api) {
  const _sectorWeekDayReport = api.models.sectorWeekDayReport;

  this.table = function (req, res) {
    const { channelId, sectorId, yearNumber, weekNumber, date } = req.query;

    _sectorWeekDayReport.table(
      { channelId, sectorId, yearNumber, weekNumber, date },
      function (exception, result) {
        if (exception) {
          return res.status(400).send(exception);
        }
        const [data] = result;
        res.status(200).send(data);
      }
    );
  };

  this.chart = function (req, res) {
    const { channelId, sectorId, yearNumber, weekNumber, dateIni, dateFin } = req.query;

    _sectorWeekDayReport.chart(
      { channelId, sectorId, yearNumber, weekNumber, dateIni, dateFin },
      function (exception, result) {
        if (exception) {
          return res.status(400).send(exception);
        }
        const [data] = result;
        res.status(200).send(data);
      }
    );
  };  

  return this;
};
