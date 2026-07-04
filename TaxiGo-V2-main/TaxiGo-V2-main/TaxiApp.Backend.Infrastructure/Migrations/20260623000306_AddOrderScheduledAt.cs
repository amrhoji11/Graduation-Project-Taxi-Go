using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TaxiApp.Backend.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddOrderScheduledAt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ScheduledAt",
                table: "Orders",
                type: "datetime2",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ScheduledAt",
                table: "Orders");
        }
    }
}
