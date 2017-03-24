import SGP4
using Base.Test 

function test_init()
    line1 = "1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753"
    line2 = "2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667"

    wgs72 = SGP4.GravityModel("wgs72")
    satellite = SGP4.twoline2rv(line1, line2, wgs72)

    @test satellite[:satnum] == 5
    return satellite
end

function test_single_time()
    satellite = test_init()

    t = Dates.DateTime(2000, 6, 29, 12, 50, 19)
    (position, velocity) = SGP4.propagate( satellite, 2000, 6, 29, 12, 50, 19)
    (position2, velocity2) = SGP4.propagate( satellite, t )

    @test satellite[:error] == 0

    @test_approx_eq_eps position[1] position2[1] eps() 
    @test_approx_eq_eps position[2] position2[2] eps()
    @test_approx_eq_eps position[3] position2[3] eps()

    @test_approx_eq_eps velocity[1] velocity2[1] eps()
    @test_approx_eq_eps velocity[2] velocity2[2] eps()
    @test_approx_eq_eps velocity[3] velocity2[3] eps()

    @test_approx_eq_eps position[1] 5576.056952 1e-6
    @test_approx_eq_eps position[2] -3999.371134 1e-6
    @test_approx_eq_eps position[3] -1521.957159 1e-6

    @test_approx_eq_eps velocity[1] 4.772627 1e-6
    @test_approx_eq_eps velocity[2] 5.119817 1e-6
    @test_approx_eq_eps velocity[3] 4.275553 1e-6
end

function test_multiple_sats()
    satellite = test_init()
    t = Dates.DateTime(2000, 6, 29, 12, 50, 19)
    sats = [satellite; satellite; satellite]

    (positions, velocities) = SGP4.propagate( sats, t )

    @test_approx_eq_eps positions[1,1] positions[1,3] eps() 
    @test_approx_eq_eps positions[2,1] positions[2,3] eps()
    @test_approx_eq_eps positions[3,1] positions[3,3] eps()

    @test_approx_eq_eps velocities[1,1] velocities[1,3] eps()  
    @test_approx_eq_eps velocities[2,1] velocities[2,3] eps()
    @test_approx_eq_eps velocities[3,1] velocities[3,3] eps()
end

function test_datetime_ephem()
    sat = test_init()
    tstart = Dates.DateTime(2000, 6, 29, 12, 50, 19)
    tstop = Dates.DateTime(2000, 6, 29, 13, 50, 19)
    (pos, vel) = SGP4.propagate(sat, tstart, tstop, 60)

    @test_approx_eq_eps pos[1,1] 5576.056952 1e-6
    @test_approx_eq_eps pos[2,1] -3999.371134 1e-6
    @test_approx_eq_eps pos[3,1] -1521.957159 1e-6

    @test_approx_eq_eps vel[1,1] 4.772627 1e-6
    @test_approx_eq_eps vel[2,1] 5.119817 1e-6
    @test_approx_eq_eps vel[3,1] 4.275553 1e-6

    @test size(pos,2) == 61
    @test size(vel,2) == 61

    (pos, vel) = SGP4.propagate(sat, tstart:Dates.Second(30):tstop)

    @test_approx_eq_eps pos[1,1] 5576.056952 1e-6
    @test_approx_eq_eps pos[2,1] -3999.371134 1e-6
    @test_approx_eq_eps pos[3,1] -1521.957159 1e-6

    @test_approx_eq_eps vel[1,1] 4.772627 1e-6
    @test_approx_eq_eps vel[2,1] 5.119817 1e-6
    @test_approx_eq_eps vel[3,1] 4.275553 1e-6

    @test size(pos,2) == 121
    @test size(vel,2) == 121
end

test_multiple_sats()
test_single_time()
test_datetime_ephem()
