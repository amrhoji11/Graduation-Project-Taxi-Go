namespace TaxiApp.Backend.Core.DTO_S
{
    public class UpdateFavoriteLocationDto
    {
        public required string Name { get; set; }
        public required string Address { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
    }
}
