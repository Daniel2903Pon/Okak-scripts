do
script_author('Jadddxxx')
script_name('eclipseMINE')

local imgui = require('mimgui')
require('lib.moonloader')
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local sampev = require("lib.samp.events")
local effil = require('effil') 
local ffi = require('ffi')
local inicfg = require('inicfg')


local recordedRoute = {  
    {x = 511.842, y = 819.245, z = -23.934, action = "MOVE"},
    {x = 511.842, y = 819.245, z = -23.934, action = "MOVE"},
    {x = 512.265, y = 818.710, z = -23.930, action = "FORWARD"},
    {x = 512.528, y = 816.703, z = -23.729, action = "FORWARD"},
    {x = 513.280, y = 814.644, z = -23.694, action = "FORWARD"},
    {x = 513.108, y = 812.810, z = -23.310, action = "FORWARD"},
    {x = 511.397, y = 810.352, z = -22.447, action = "FORWARD"},
    {x = 509.504, y = 808.186, z = -22.445, action = "FORWARD"},
    {x = 506.328, y = 807.716, z = -21.617, action = "FORWARD"},
    {x = 503.683, y = 806.976, z = -21.945, action = "FORWARD"},
    {x = 502.535, y = 803.903, z = -21.265, action = "JUMP"},
    {x = 501.513, y = 800.965, z = -21.950, action = "FORWARD"},
    {x = 501.269, y = 798.733, z = -21.956, action = "JUMP"},
    {x = 501.354, y = 796.131, z = -21.961, action = "FORWARD"},
    {x = 502.643, y = 793.946, z = -21.989, action = "FORWARD"},
    {x = 504.611, y = 793.265, z = -22.001, action = "FORWARD"},
    {x = 507.263, y = 793.302, z = -21.997, action = "FORWARD"},
    {x = 509.403, y = 793.157, z = -22.005, action = "FORWARD"},
    {x = 510.659, y = 794.793, z = -21.965, action = "FORWARD"},
    {x = 511.067, y = 796.819, z = -21.945, action = "JUMP"},
    {x = 513.766, y = 798.842, z = -22.048, action = "JUMP"},
    {x = 516.269, y = 800.510, z = -22.477, action = "JUMP"},
    {x = 516.151, y = 802.985, z = -22.693, action = "JUMP"},
    {x = 513.760, y = 804.334, z = -22.555, action = "JUMP"},
    {x = 510.782, y = 803.955, z = -22.193, action = "JUMP"},
    {x = 508.220, y = 802.376, z = -21.945, action = "JUMP"},
    {x = 507.851, y = 799.473, z = -21.945, action = "JUMP"},
    {x = 509.841, y = 797.529, z = -21.945, action = "JUMP"},
    {x = 512.811, y = 796.937, z = -21.937, action = "JUMP"},
    {x = 515.798, y = 796.565, z = -21.849, action = "JUMP"},
    {x = 518.694, y = 795.687, z = -21.728, action = "JUMP"},
    {x = 521.456, y = 794.602, z = -21.410, action = "JUMP"},
    {x = 523.917, y = 793.113, z = -21.124, action = "JUMP"},
    {x = 525.717, y = 790.731, z = -21.063, action = "JUMP"},
    {x = 527.486, y = 788.300, z = -20.957, action = "JUMP"},
    {x = 529.369, y = 786.043, z = -20.733, action = "JUMP"},
    {x = 532.027, y = 785.168, z = -20.426, action = "JUMP"},
    {x = 533.171, y = 787.826, z = -20.385, action = "JUMP"},
    {x = 533.043, y = 790.369, z = -20.476, action = "JUMP"},
    {x = 535.751, y = 789.429, z = -20.161, action = "JUMP"},
    {x = 538.518, y = 788.254, z = -19.833, action = "JUMP"},
    {x = 540.943, y = 786.618, z = -19.528, action = "JUMP"},
    {x = 540.836, y = 784.597, z = -19.478, action = "JUMP"},
    {x = 538.629, y = 786.560, z = -19.770, action = "JUMP"},
    {x = 536.578, y = 788.771, z = -20.054, action = "JUMP"},
    {x = 533.913, y = 790.213, z = -20.379, action = "JUMP"},
    {x = 531.643, y = 792.106, z = -20.624, action = "JUMP"},
    {x = 530.123, y = 794.615, z = -21.177, action = "JUMP"},
    {x = 529.012, y = 797.422, z = -21.722, action = "JUMP"},
    {x = 527.618, y = 799.875, z = -22.362, action = "JUMP"},
    {x = 525.959, y = 802.306, z = -23.000, action = "JUMP"},
    {x = 524.636, y = 804.949, z = -23.688, action = "JUMP"},
    {x = 524.662, y = 807.600, z = -24.596, action = "JUMP"},
    {x = 526.945, y = 809.176, z = -25.589, action = "JUMP"},
    {x = 529.791, y = 809.924, z = -26.093, action = "JUMP"},
    {x = 532.701, y = 809.671, z = -26.398, action = "JUMP"},
    {x = 535.291, y = 808.190, z = -26.024, action = "JUMP"},
    {x = 537.528, y = 806.240, z = -25.488, action = "JUMP"},
    {x = 539.785, y = 804.370, z = -24.979, action = "JUMP"},
    {x = 542.334, y = 802.758, z = -24.562, action = "JUMP"},
    {x = 545.126, y = 801.558, z = -24.403, action = "JUMP"},
    {x = 547.884, y = 800.755, z = -24.994, action = "JUMP"},
    {x = 550.730, y = 800.068, z = -25.695, action = "JUMP"},
    {x = 553.616, y = 799.400, z = -26.407, action = "JUMP"},
    {x = 556.504, y = 798.765, z = -27.120, action = "JUMP"},
    {x = 559.370, y = 798.751, z = -27.844, action = "JUMP"},
    {x = 562.343, y = 798.670, z = -28.157, action = "JUMP"},
    {x = 565.259, y = 797.934, z = -28.226, action = "JUMP"},
    {x = 568.030, y = 796.804, z = -28.466, action = "JUMP"},
    {x = 570.862, y = 795.834, z = -28.706, action = "JUMP"},
    {x = 573.809, y = 794.935, z = -28.953, action = "JUMP"},
    {x = 576.742, y = 794.101, z = -29.220, action = "JUMP"},
    {x = 579.550, y = 793.181, z = -29.601, action = "JUMP"},
    {x = 582.387, y = 792.134, z = -29.935, action = "JUMP"},
    {x = 585.185, y = 791.049, z = -30.265, action = "JUMP"},
    {x = 588.062, y = 790.189, z = -30.602, action = "JUMP"},
    {x = 591.001, y = 789.469, z = -30.945, action = "JUMP"},
    {x = 593.894, y = 788.766, z = -31.283, action = "JUMP"},
    {x = 596.752, y = 788.097, z = -31.617, action = "JUMP"},
    {x = 599.703, y = 787.532, z = -31.961, action = "JUMP"},
    {x = 602.735, y = 786.952, z = -32.077, action = "JUMP"},
    {x = 605.760, y = 786.334, z = -32.085, action = "JUMP"},
    {x = 608.629, y = 785.662, z = -32.084, action = "JUMP"},
    {x = 611.479, y = 784.818, z = -32.083, action = "JUMP"},
    {x = 614.380, y = 783.829, z = -32.083, action = "JUMP"},
    {x = 616.956, y = 782.515, z = -32.084, action = "JUMP"},
    {x = 618.734, y = 780.166, z = -32.089, action = "JUMP"},
    {x = 621.486, y = 779.686, z = -31.915, action = "JUMP"},
    {x = 623.979, y = 780.886, z = -31.688, action = "FORWARD"},
    {x = 626.353, y = 781.842, z = -31.474, action = "FORWARD"},
    {x = 628.400, y = 781.279, z = -31.325, action = "FORWARD"},
    {x = 630.590, y = 781.649, z = -31.153, action = "FORWARD"},
    {x = 632.752, y = 781.124, z = -30.996, action = "FORWARD"},
    {x = 634.962, y = 780.580, z = -30.836, action = "JUMP"},
    {x = 637.774, y = 779.946, z = -30.632, action = "JUMP"},
    {x = 640.697, y = 779.647, z = -30.414, action = "JUMP"},
    {x = 643.682, y = 780.087, z = -30.225, action = "JUMP"},
    {x = 646.568, y = 780.661, z = -30.224, action = "JUMP"},
    {x = 649.562, y = 780.708, z = -30.226, action = "JUMP"},
    {x = 652.615, y = 781.031, z = -30.225, action = "JUMP"},
    {x = 655.564, y = 781.444, z = -30.225, action = "JUMP"},
    {x = 658.504, y = 781.995, z = -30.221, action = "JUMP"},
    {x = 661.498, y = 782.661, z = -30.221, action = "JUMP"},
    {x = 664.527, y = 783.359, z = -30.231, action = "JUMP"},
    {x = 667.309, y = 784.362, z = -30.231, action = "JUMP"},
    {x = 670.173, y = 785.383, z = -30.231, action = "JUMP"},
    {x = 673.110, y = 786.337, z = -30.227, action = "JUMP"},
    {x = 675.557, y = 787.934, z = -30.229, action = "JUMP"},
    {x = 677.431, y = 790.329, z = -30.229, action = "JUMP"},
    {x = 679.853, y = 792.135, z = -30.226, action = "JUMP"},
    {x = 682.675, y = 793.026, z = -30.227, action = "JUMP"},
    {x = 685.508, y = 792.054, z = -30.232, action = "JUMP"},
    {x = 686.030, y = 789.802, z = -30.239, action = "JUMP"},
    {x = 683.427, y = 788.192, z = -30.240, action = "JUMP"},
    {x = 680.822, y = 789.106, z = -30.235, action = "JUMP"},
    {x = 680.706, y = 792.436, z = -30.226, action = "MOVE"},
    {x = 680.714, y = 793.609, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.714, y = 793.638, z = -30.223, action = "MOVE"},
    {x = 680.603, y = 793.832, z = -30.223, action = "JUMP"},
    {x = 680.570, y = 792.785, z = -30.225, action = "JUMP"},
    {x = 683.282, y = 792.986, z = -30.227, action = "JUMP"},
    {x = 685.917, y = 794.201, z = -30.222, action = "JUMP"},
    {x = 688.726, y = 795.297, z = -30.234, action = "JUMP"},
    {x = 691.586, y = 796.433, z = -30.235, action = "JUMP"},
    {x = 694.422, y = 797.521, z = -30.236, action = "JUMP"},
    {x = 697.241, y = 798.269, z = -30.238, action = "JUMP"},
    {x = 700.317, y = 798.328, z = -30.239, action = "JUMP"},
    {x = 703.163, y = 799.119, z = -30.243, action = "FORWARD"},
    {x = 704.619, y = 801.287, z = -30.243, action = "RIGHT"},
    {x = 705.140, y = 803.516, z = -30.241, action = "JUMP"},
    {x = 704.103, y = 806.219, z = -30.235, action = "JUMP"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.158, y = 806.075, z = -30.235, action = "MOVE"},
    {x = 704.181, y = 806.126, z = -30.235, action = "FORWARD"},
    {x = 705.069, y = 806.755, z = -30.236, action = "FORWARD"},
    {x = 707.143, y = 807.444, z = -30.239, action = "FORWARD"},
    {x = 708.931, y = 808.749, z = -30.241, action = "FORWARD"},
    {x = 710.297, y = 810.492, z = -30.241, action = "FORWARD"},
    {x = 710.607, y = 812.517, z = -30.241, action = "FORWARD"},
    {x = 711.083, y = 814.628, z = -30.241, action = "JUMP"},
    {x = 711.353, y = 817.426, z = -30.240, action = "JUMP"},
    {x = 713.132, y = 819.755, z = -30.245, action = "JUMP"},
    {x = 713.981, y = 822.687, z = -30.245, action = "FORWARD"},
    {x = 714.516, y = 825.313, z = -30.236, action = "FORWARD"},
    {x = 714.819, y = 827.541, z = -30.235, action = "FORWARD"},
    {x = 716.239, y = 829.198, z = -30.237, action = "FORWARD"},
    {x = 717.212, y = 831.438, z = -30.238, action = "JUMP"},
    {x = 717.768, y = 834.091, z = -30.242, action = "JUMP"},
    {x = 718.191, y = 836.800, z = -30.242, action = "JUMP"},
    {x = 717.419, y = 839.629, z = -30.239, action = "JUMP"},
    {x = 716.757, y = 842.514, z = -30.231, action = "JUMP"},
    {x = 716.666, y = 845.419, z = -30.231, action = "JUMP"},
    {x = 715.962, y = 848.451, z = -30.229, action = "JUMP"},
    {x = 715.103, y = 851.354, z = -30.225, action = "JUMP"},
    {x = 715.548, y = 854.255, z = -30.225, action = "JUMP"},
    {x = 716.559, y = 856.980, z = -30.227, action = "FORWARD"},
    {x = 716.600, y = 859.943, z = -29.662, action = "JUMP"},
    {x = 718.370, y = 862.269, z = -29.121, action = "JUMP"},
    {x = 719.772, y = 864.811, z = -28.552, action = "JUMP"},
    {x = 720.499, y = 867.605, z = -27.960, action = "JUMP"},
    {x = 720.667, y = 870.555, z = -27.360, action = "JUMP"},
    {x = 720.705, y = 873.501, z = -26.901, action = "JUMP"},
    {x = 720.712, y = 876.483, z = -26.800, action = "JUMP"},
    {x = 720.719, y = 879.466, z = -26.600, action = "JUMP"},
    {x = 720.635, y = 882.511, z = -26.545, action = "JUMP"},
    {x = 719.194, y = 885.124, z = -26.623, action = "JUMP"},
    {x = 717.337, y = 887.573, z = -26.742, action = "JUMP"},
    {x = 715.142, y = 889.709, z = -26.932, action = "JUMP"},
    {x = 713.504, y = 892.178, z = -27.121, action = "FORWARD"},
    {x = 712.104, y = 894.356, z = -27.318, action = "FORWARD"},
    {x = 710.739, y = 896.228, z = -27.751, action = "FORWARD"},
    {x = 709.141, y = 898.421, z = -28.418, action = "FORWARD"},
    {x = 707.580, y = 900.563, z = -29.200, action = "FORWARD"},
    {x = 706.323, y = 902.428, z = -29.877, action = "FORWARD"},
    {x = 705.177, y = 904.197, z = -30.518, action = "FORWARD"},
    {x = 703.988, y = 906.049, z = -30.629, action = "FORWARD"},
    {x = 702.654, y = 908.131, z = -30.578, action = "FORWARD"},
    {x = 701.429, y = 909.951, z = -30.545, action = "FORWARD"},
    {x = 700.120, y = 911.831, z = -30.537, action = "JUMP"},
    {x = 698.437, y = 914.250, z = -30.526, action = "JUMP"},
    {x = 696.712, y = 916.728, z = -30.436, action = "JUMP"},
    {x = 695.009, y = 919.176, z = -30.347, action = "JUMP"},
    {x = 693.232, y = 921.728, z = -30.254, action = "JUMP"},
    {x = 691.507, y = 924.206, z = -30.192, action = "JUMP"},
    {x = 689.782, y = 926.670, z = -30.191, action = "JUMP"},
    {x = 688.035, y = 929.093, z = -30.191, action = "FORWARD"},
    {x = 686.426, y = 931.470, z = -30.191, action = "FORWARD"},
    {x = 684.942, y = 933.304, z = -30.185, action = "FORWARD"},
    {x = 683.397, y = 935.196, z = -30.190, action = "JUMP"},
    {x = 681.283, y = 937.311, z = -30.200, action = "JUMP"},
    {x = 678.719, y = 938.944, z = -30.206, action = "JUMP"},
    {x = 676.035, y = 940.480, z = -30.452, action = "JUMP"},
    {x = 673.517, y = 941.954, z = -31.272, action = "JUMP"},
    {x = 670.996, y = 943.453, z = -32.101, action = "JUMP"},
    {x = 668.397, y = 944.997, z = -32.673, action = "JUMP"},
    {x = 665.827, y = 946.275, z = -33.503, action = "JUMP"},
    {x = 663.216, y = 947.378, z = -34.312, action = "JUMP"},
    {x = 660.368, y = 947.858, z = -34.804, action = "JUMP"},
    {x = 658.169, y = 945.855, z = -35.040, action = "JUMP"},
    {x = 658.551, y = 943.009, z = -35.671, action = "JUMP"},
    {x = 659.632, y = 940.405, z = -36.648, action = "JUMP"},
    {x = 657.839, y = 938.994, z = -36.718, action = "JUMP"},
    {x = 656.167, y = 941.302, z = -35.997, action = "JUMP"},
    {x = 654.240, y = 941.413, z = -35.928, action = "JUMP"},
    {x = 656.394, y = 939.503, z = -36.451, action = "JUMP"},
    {x = 658.066, y = 941.441, z = -36.040, action = "JUMP"},
    {x = 656.114, y = 940.499, z = -36.196, action = "JUMP"},
    {x = 658.586, y = 939.349, z = -36.758, action = "JUMP"},
    {x = 657.867, y = 941.211, z = -36.069, action = "JUMP"},
    {x = 657.414, y = 939.140, z = -36.593, action = "FORWARD"},
    {x = 658.926, y = 940.473, z = -36.492, action = "FORWARD"},
    {x = 656.855, y = 941.039, z = -36.077, action = "FORWARD"},
    {x = 655.198, y = 942.372, z = -35.709, action = "FORWARD"},
    {x = 653.207, y = 942.503, z = -35.634, action = "FORWARD"},
    {x = 651.098, y = 942.500, z = -35.590, action = "JUMP"},
    {x = 649.479, y = 944.829, z = -35.211, action = "JUMP"},
    {x = 650.689, y = 947.395, z = -35.017, action = "JUMP"},
    {x = 649.412, y = 949.983, z = -34.809, action = "JUMP"},
    {x = 646.426, y = 950.220, z = -34.778, action = "JUMP"},
    {x = 643.422, y = 950.732, z = -34.727, action = "JUMP"},
    {x = 640.403, y = 951.109, z = -34.823, action = "JUMP"},
    {x = 637.440, y = 950.358, z = -34.997, action = "JUMP"},
    {x = 634.686, y = 949.225, z = -35.186, action = "JUMP"},
    {x = 632.028, y = 947.890, z = -35.394, action = "JUMP"},
    {x = 629.508, y = 946.341, z = -35.592, action = "JUMP"},
    {x = 628.265, y = 943.747, z = -36.247, action = "JUMP"},
    {x = 625.714, y = 943.074, z = -36.609, action = "JUMP"},
    {x = 625.701, y = 945.576, z = -35.920, action = "JUMP"},
    {x = 628.192, y = 947.336, z = -35.569, action = "JUMP"},
    {x = 629.378, y = 949.615, z = -35.324, action = "JUMP"},
    {x = 626.830, y = 950.498, z = -35.235, action = "JUMP"},
    {x = 623.790, y = 950.346, z = -35.195, action = "JUMP"},
    {x = 620.891, y = 950.773, z = -34.644, action = "JUMP"},
    {x = 618.087, y = 950.200, z = -34.265, action = "JUMP"},
    {x = 615.088, y = 950.103, z = -33.779, action = "JUMP"},
    {x = 612.031, y = 949.747, z = -33.324, action = "JUMP"},
    {x = 609.019, y = 949.397, z = -33.144, action = "JUMP"},
    {x = 605.989, y = 949.045, z = -33.019, action = "JUMP"},
    {x = 602.928, y = 948.732, z = -32.895, action = "JUMP"},
    {x = 599.896, y = 948.430, z = -32.591, action = "JUMP"},
    {x = 596.906, y = 948.132, z = -32.194, action = "JUMP"},
    {x = 593.979, y = 947.840, z = -31.806, action = "JUMP"},
    {x = 591.020, y = 947.545, z = -31.451, action = "JUMP"},
    {x = 588.042, y = 947.248, z = -31.098, action = "JUMP"},
    {x = 585.055, y = 946.950, z = -30.789, action = "JUMP"},
    {x = 582.029, y = 946.646, z = -30.725, action = "JUMP"},
    {x = 579.044, y = 946.204, z = -30.657, action = "JUMP"},
    {x = 576.079, y = 945.744, z = -30.576, action = "JUMP"},
    {x = 573.213, y = 946.141, z = -30.491, action = "BACKWARD"},
    {x = 570.264, y = 945.732, z = -30.384, action = "JUMP"},
    {x = 567.414, y = 946.208, z = -30.301, action = "FORWARD"},
    {x = 564.706, y = 945.744, z = -30.053, action = "JUMP"},
    {x = 561.788, y = 945.289, z = -29.391, action = "JUMP"},
    {x = 558.905, y = 944.739, z = -28.726, action = "JUMP"},
    {x = 556.080, y = 943.987, z = -28.052, action = "JUMP"},
    {x = 553.184, y = 943.749, z = -27.397, action = "JUMP"},
    {x = 550.382, y = 943.058, z = -26.713, action = "JUMP"},
    {x = 547.656, y = 942.160, z = -26.026, action = "JUMP"},
    {x = 545.271, y = 940.526, z = -25.344, action = "JUMP"},
    {x = 542.704, y = 939.174, z = -24.648, action = "JUMP"},
    {x = 540.250, y = 937.740, z = -24.016, action = "JUMP"},
    {x = 537.755, y = 936.624, z = -24.017, action = "JUMP"},
    {x = 535.528, y = 935.287, z = -24.016, action = "JUMP"},
    {x = 532.578, y = 935.644, z = -24.176, action = "JUMP"},
    {x = 529.848, y = 935.957, z = -24.460, action = "FORWARD"},
    {x = 524.366, y = 936.584, z = -24.716, action = "FORWARD"},
    {x = 521.704, y = 936.883, z = -25.308, action = "JUMP"},
    {x = 516.472, y = 937.452, z = -25.478, action = "FORWARD"},
    {x = 513.638, y = 937.666, z = -26.788, action = "FORWARD"},
    {x = 511.577, y = 938.456, z = -27.153, action = "FORWARD"},
    {x = 509.499, y = 939.148, z = -27.514, action = "FORWARD"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.445, action = "MOVE"},
    {x = 508.476, y = 938.693, z = -27.723, action = "MOVE"},
    {x = 508.876, y = 938.374, z = -27.656, action = "FORWARD"},
    {x = 509.491, y = 940.166, z = -27.419, action = "FORWARD"},
    {x = 510.837, y = 941.865, z = -27.010, action = "FORWARD"},
    {x = 512.174, y = 943.552, z = -26.603, action = "JUMP"},
    {x = 514.332, y = 944.851, z = -26.081, action = "JUMP"},
    {x = 516.643, y = 946.576, z = -25.490, action = "JUMP"},
    {x = 519.032, y = 948.165, z = -24.872, action = "JUMP"},
    {x = 521.475, y = 949.473, z = -24.228, action = "JUMP"},
    {x = 522.205, y = 952.358, z = -23.789, action = "JUMP"},
    {x = 522.844, y = 955.305, z = -23.549, action = "JUMP"},
    {x = 523.484, y = 958.250, z = -23.378, action = "JUMP"},
    {x = 525.060, y = 960.736, z = -23.051, action = "JUMP"},
    {x = 524.608, y = 963.650, z = -23.074, action = "JUMP"},
    {x = 522.859, y = 965.961, z = -23.337, action = "JUMP"},
    {x = 520.759, y = 968.061, z = -23.667, action = "JUMP"},
    {x = 519.277, y = 967.016, z = -23.949, action = "JUMP"},
    {x = 522.129, y = 967.150, z = -23.443, action = "JUMP"},
    {x = 524.796, y = 965.865, z = -23.030, action = "JUMP"},
    {x = 527.508, y = 966.772, z = -22.664, action = "JUMP"},
    {x = 530.376, y = 967.770, z = -22.278, action = "JUMP"},
    {x = 533.305, y = 967.923, z = -21.879, action = "JUMP"},
    {x = 536.305, y = 967.802, z = -21.468, action = "JUMP"},
    {x = 539.022, y = 966.955, z = -21.093, action = "JUMP"},
    {x = 537.519, y = 964.731, z = -21.287, action = "JUMP"},
    {x = 536.041, y = 963.197, z = -21.481, action = "JUMP"},
    {x = 538.158, y = 961.338, z = -21.182, action = "JUMP"},
    {x = 541.054, y = 960.790, z = -20.784, action = "JUMP"},
    {x = 543.419, y = 962.025, z = -20.467, action = "JUMP"},
    {x = 541.244, y = 963.193, z = -20.770, action = "JUMP"},
    {x = 540.697, y = 960.998, z = -20.834, action = "JUMP"},
    {x = 543.289, y = 960.091, z = -20.475, action = "JUMP"},
    {x = 544.228, y = 962.164, z = -20.358, action = "JUMP"},
    {x = 542.131, y = 964.261, z = -20.655, action = "JUMP"},
    {x = 539.241, y = 963.681, z = -21.046, action = "JUMP"},
    {x = 536.430, y = 962.973, z = -21.426, action = "JUMP"},
    {x = 533.418, y = 962.677, z = -21.836, action = "JUMP"},
    {x = 530.412, y = 962.385, z = -22.245, action = "JUMP"},
    {x = 527.461, y = 962.203, z = -22.647, action = "JUMP"},
    {x = 526.177, y = 964.700, z = -22.835, action = "JUMP"},
    {x = 523.900, y = 962.988, z = -23.212, action = "JUMP"},
    {x = 523.296, y = 960.309, z = -23.371, action = "FORWARD"},
    {x = 521.827, y = 955.063, z = -23.578, action = "FORWARD"},
    {x = 520.807, y = 952.417, z = -24.077, action = "FORWARD"},
    {x = 519.826, y = 950.126, z = -24.511, action = "FORWARD"},
    {x = 518.170, y = 948.755, z = -24.995, action = "FORWARD"},
    {x = 517.207, y = 946.803, z = -25.364, action = "RIGHT"},
    {x = 516.824, y = 944.712, z = -25.631, action = "FORWARD"},
    {x = 515.708, y = 942.179, z = -26.077, action = "FORWARD"},
    {x = 514.184, y = 940.123, z = -26.553, action = "FORWARD"},
    {x = 512.674, y = 938.377, z = -26.951, action = "JUMP"},
    {x = 511.176, y = 936.546, z = -27.269, action = "FORWARD"},
    {x = 509.815, y = 934.865, z = -27.584, action = "FORWARD"},
    {x = 508.352, y = 933.067, z = -28.074, action = "JUMP"},
    {x = 506.556, y = 930.861, z = -28.676, action = "JUMP"},
    {x = 504.709, y = 928.591, z = -29.295, action = "JUMP"},
    {x = 502.772, y = 926.219, z = -29.356, action = "JUMP"},
    {x = 500.612, y = 924.060, z = -29.249, action = "JUMP"},
    {x = 498.874, y = 921.628, z = -29.491, action = "JUMP"},
    {x = 497.153, y = 919.180, z = -30.037, action = "JUMP"},
    {x = 495.542, y = 916.618, z = -30.350, action = "JUMP"},
    {x = 494.120, y = 913.965, z = -30.691, action = "JUMP"},
    {x = 493.413, y = 911.123, z = -30.792, action = "JUMP"},
    {x = 492.765, y = 908.157, z = -30.808, action = "JUMP"},
    {x = 490.908, y = 905.772, z = -30.670, action = "JUMP"},
    {x = 489.192, y = 903.309, z = -30.654, action = "JUMP"},
    {x = 487.379, y = 900.849, z = -30.629, action = "JUMP"},
    {x = 485.613, y = 898.349, z = -30.611, action = "JUMP"},
    {x = 483.639, y = 896.131, z = -30.558, action = "JUMP"},
    {x = 481.909, y = 893.647, z = -30.541, action = "JUMP"},
    {x = 480.615, y = 890.884, z = -30.435, action = "JUMP"},
    {x = 480.146, y = 887.946, z = -30.417, action = "JUMP"},
    {x = 480.742, y = 885.010, z = -30.463, action = "JUMP"},
    {x = 482.816, y = 883.000, z = -30.586, action = "JUMP"},
    {x = 485.685, y = 882.062, z = -30.687, action = "JUMP"},
    {x = 487.814, y = 880.120, z = -30.952, action = "JUMP"},
    {x = 488.900, y = 877.339, z = -31.246, action = "JUMP"},
    {x = 489.053, y = 874.330, z = -31.178, action = "JUMP"},
    {x = 488.876, y = 871.375, z = -31.188, action = "JUMP"},
    {x = 488.781, y = 868.302, z = -31.213, action = "JUMP"},
    {x = 489.248, y = 865.430, z = -30.679, action = "JUMP"},
    {x = 490.223, y = 862.625, z = -30.209, action = "JUMP"},
    {x = 491.261, y = 859.834, z = -29.955, action = "JUMP"},
    {x = 492.466, y = 856.976, z = -29.879, action = "JUMP"},
    {x = 493.706, y = 854.137, z = -29.821, action = "JUMP"},
    {x = 495.082, y = 851.515, z = -29.879, action = "JUMP"},
    {x = 496.685, y = 848.989, z = -29.698, action = "JUMP"},
    {x = 499.013, y = 846.987, z = -29.426, action = "JUMP"},
    {x = 501.485, y = 845.253, z = -29.268, action = "JUMP"},
    {x = 503.455, y = 843.008, z = -29.088, action = "JUMP"},
    {x = 504.778, y = 840.404, z = -28.327, action = "JUMP"},
    {x = 506.095, y = 837.752, z = -27.508, action = "JUMP"},
    {x = 507.372, y = 835.166, z = -26.590, action = "JUMP"},
    {x = 508.785, y = 832.646, z = -25.873, action = "JUMP"},
    {x = 510.028, y = 829.948, z = -25.097, action = "JUMP"},
    {x = 510.623, y = 826.987, z = -24.663, action = "JUMP"},
    {x = 511.605, y = 824.192, z = -24.488, action = "JUMP"},
    {x = 513.191, y = 821.672, z = -24.413, action = "JUMP"},
    {x = 515.813, y = 820.631, z = -24.628, action = "JUMP"},
    {x = 518.420, y = 821.652, z = -25.032, action = "JUMP"},
    {x = 519.681, y = 824.315, z = -25.444, action = "JUMP"},
    {x = 521.962, y = 825.646, z = -25.842, action = "JUMP"},
    {x = 524.936, y = 825.555, z = -26.177, action = "JUMP"},
    {x = 527.592, y = 824.417, z = -26.371, action = "JUMP"},
    {x = 529.029, y = 821.836, z = -26.479, action = "JUMP"},
    {x = 529.598, y = 819.026, z = -26.477, action = "JUMP"},
    {x = 531.009, y = 816.412, z = -26.601, action = "JUMP"},
    {x = 532.247, y = 813.677, z = -26.690, action = "JUMP"},
    {x = 532.437, y = 810.641, z = -26.478, action = "JUMP"},
    {x = 532.086, y = 807.808, z = -25.785, action = "JUMP"},
    {x = 531.195, y = 805.088, z = -24.649, action = "JUMP"},
    {x = 530.148, y = 802.670, z = -23.218, action = "JUMP"},
    {x = 529.453, y = 799.943, z = -22.363, action = "JUMP"},
    {x = 529.117, y = 797.382, z = -21.711, action = "JUMP"},
    {x = 529.652, y = 794.483, z = -21.160, action = "JUMP"},
    {x = 531.652, y = 792.510, z = -20.663, action = "JUMP"},
    {x = 534.187, y = 790.998, z = -20.374, action = "JUMP"},
    {x = 536.789, y = 789.444, z = -20.052, action = "JUMP"},
    {x = 539.371, y = 787.879, z = -19.732, action = "JUMP"},
    {x = 541.881, y = 786.287, z = -19.419, action = "JUMP"},
    {x = 544.375, y = 784.631, z = -19.105, action = "JUMP"},
    {x = 546.856, y = 782.985, z = -18.813, action = "JUMP"},
    {x = 549.377, y = 781.309, z = -18.555, action = "JUMP"},
    {x = 551.832, y = 779.641, z = -18.316, action = "JUMP"},
    {x = 554.376, y = 777.912, z = -18.077, action = "JUMP"},
    {x = 556.866, y = 776.219, z = -17.843, action = "JUMP"},
    {x = 559.284, y = 774.576, z = -17.561, action = "JUMP"},
    {x = 561.735, y = 772.857, z = -17.250, action = "JUMP"},
    {x = 564.222, y = 771.116, z = -16.935, action = "FORWARD"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.630, y = 770.102, z = -16.364, action = "MOVE"},
    {x = 565.723, y = 769.976, z = -16.741, action = "JUMP"},
    {x = 564.537, y = 769.962, z = -16.864, action = "JUMP"},
    {x = 562.181, y = 771.406, z = -17.156, action = "JUMP"},
    {x = 559.800, y = 773.231, z = -17.463, action = "JUMP"},
    {x = 557.443, y = 774.986, z = -17.766, action = "JUMP"},
    {x = 554.556, y = 776.038, z = -18.059, action = "JUMP"},
    {x = 551.773, y = 777.170, z = -18.319, action = "JUMP"},
    {x = 549.119, y = 778.388, z = -18.568, action = "JUMP"},
    {x = 546.589, y = 779.978, z = -18.825, action = "JUMP"},
    {x = 544.097, y = 781.589, z = -19.080, action = "JUMP"},
    {x = 541.481, y = 782.810, z = -19.356, action = "FORWARD"},
    {x = 538.657, y = 783.783, z = -19.684, action = "FORWARD"},
    {x = 536.281, y = 784.927, z = -19.969, action = "FORWARD"},
    {x = 534.195, y = 786.026, z = -20.223, action = "JUMP"},
    {x = 531.708, y = 787.323, z = -20.525, action = "FORWARD"},
    {x = 529.031, y = 788.653, z = -20.829, action = "FORWARD"},
    {x = 526.725, y = 789.807, z = -21.019, action = "FORWARD"},
    {x = 525.305, y = 791.587, z = -21.069, action = "FORWARD"},
    {x = 523.367, y = 792.595, z = -21.175, action = "FORWARD"},
    {x = 521.742, y = 793.999, z = -21.267, action = "LEFT"},
    {x = 520.923, y = 794.904, z = -21.492, action = "MOVE"},
    {x = 520.923, y = 794.904, z = -21.492, action = "MOVE"},
    {x = 520.923, y = 794.904, z = -21.492, action = "MOVE"},
    {x = 520.923, y = 794.904, z = -21.492, action = "MOVE"},
    {x = 520.923, y = 794.904, z = -21.492, action = "MOVE"},
}

local mode = false
local sprint = true
local renderRadius = 1000
local totalStone = 0
local totalMetal = 0
local totalSilver = 0
local totalBronze = 0
local totalGold = 0
local collisionEnabled = false

local currentRoutePoint = 1
local routeCheckDistance = 5.0
local routeOreRadius = 15.0

local farmStartTime = 0
local afkAfterHour = true
local afkDuration = 600
local isAfk = false

local orePriority = {
    [5] = 5,
    [3] = 4,
    [4] = 3,
    [2] = 2,
    [1] = 1
}

local oreNames = {
    [1] = u8"Камень",
    [2] = u8"Металл",
    [3] = u8"Серебро",
    [4] = u8"Бронза",
    [5] = u8"Золото"
}

local oreTextures = {
    ['cs_rockdetail2'] = 1,
    ['ab_flakeywall'] = 2,
    ['metalic128'] = 3,
    ['Strip_Gold'] = 4,
    ['gold128'] = 5
}
local resources = {}

local WinState = imgui.new.bool()
local WinStats = imgui.new.bool()
local SliderInt = imgui.new.int(1000)
local PrioritySliders = {
    imgui.new.int(1),
    imgui.new.int(2),
    imgui.new.int(3),
    imgui.new.int(4),
    imgui.new.int(5)
}

local currentCameraAngle = 0
local targetCameraAngle = 0
local lastMiningAttempt = 0
local miningTimeout = 10
local currentMiningTarget = nil

local configs = {}
local currentConfig = "default"
local configName = imgui.new.char[256]("default")

local mainIni = inicfg.load({
    main = {
        currentConfig = "default"
    },
    priority = {
        stone = 1,
        metal = 2,
        silver = 3,
        bronze = 4,
        gold = 5
    }
}, 'autominev2.ini')

if not doesFileExist('moonloader/config/autominev2.ini') then
    inicfg.save(mainIni, 'autominev2.ini')
end

PrioritySliders[1][0] = mainIni.priority.stone
PrioritySliders[2][0] = mainIni.priority.metal
PrioritySliders[3][0] = mainIni.priority.silver
PrioritySliders[4][0] = mainIni.priority.bronze
PrioritySliders[5][0] = mainIni.priority.gold

orePriority[1] = mainIni.priority.stone
orePriority[2] = mainIni.priority.metal
orePriority[3] = mainIni.priority.silver
orePriority[4] = mainIni.priority.bronze
orePriority[5] = mainIni.priority.gold

function loadConfigs()
    configs = {}
    table.insert(configs, "default")
    
    local possibleConfigs = {"main", "fast", "slow", "test"}
    for _, name in ipairs(possibleConfigs) do
        if doesFileExist("moonloader/config/autominev2_" .. name .. ".ini") then
            table.insert(configs, name)
        end
    end
end

function saveConfig(name)
    local configData = {
        priority = {
            stone = PrioritySliders[1][0],
            metal = PrioritySliders[2][0],
            silver = PrioritySliders[3][0],
            bronze = PrioritySliders[4][0],
            gold = PrioritySliders[5][0]
        }
    }
    inicfg.save(configData, "autominev2_" .. name .. ".ini")
end

function loadConfig(name)
    if name == "default" then
        local configData = inicfg.load(nil, 'autominev2.ini')
        PrioritySliders[1][0] = configData.priority.stone
        PrioritySliders[2][0] = configData.priority.metal
        PrioritySliders[3][0] = configData.priority.silver
        PrioritySliders[4][0] = configData.priority.bronze
        PrioritySliders[5][0] = configData.priority.gold
    else
        local configData = inicfg.load(nil, "autominev2_" .. name .. ".ini")
        if configData.priority then
            PrioritySliders[1][0] = configData.priority.stone
            PrioritySliders[2][0] = configData.priority.metal
            PrioritySliders[3][0] = configData.priority.silver
            PrioritySliders[4][0] = configData.priority.bronze
            PrioritySliders[5][0] = configData.priority.gold
        end
    end
    orePriority[1] = PrioritySliders[1][0]
    orePriority[2] = PrioritySliders[2][0]
    orePriority[3] = PrioritySliders[3][0]
    orePriority[4] = PrioritySliders[4][0]
    orePriority[5] = PrioritySliders[5][0]
end

function isPlayerNearPosition(x, y, z, radius)
    for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) then
            local result, ped = sampGetCharHandleBySampPlayerId(i)
            if result and doesCharExist(ped) and ped ~= PLAYER_PED then
                local px, py, pz = getCharCoordinates(ped)
                local dist = getDistanceBetweenCoords3d(px, py, pz, x, y, z)
                if dist <= radius then
                    return true
                end
            end
        end
    end
    return false
end

function enableCollision()
    for k, v in ipairs(getAllChars()) do
        if doesCharExist(v) and v ~= PLAYER_PED then
            setCharCollision(v, not collisionEnabled)
        end
    end
    for k, v in ipairs(getAllVehicles()) do
        if doesVehicleExist(v) then
            setCarCollision(v, not collisionEnabled)
        end
    end
    for k, v in ipairs(getAllObjects()) do
        if doesObjectExist(v) then
            setObjectCollision(v, not collisionEnabled)
        end
    end
end

function smoothCameraRotation()
    local angleDiff = targetCameraAngle - currentCameraAngle
    while angleDiff > 180 do angleDiff = angleDiff - 360 end
    while angleDiff < -180 do angleDiff = angleDiff + 360 end
    if math.abs(angleDiff) > 1 then
        local step = angleDiff * 0.1
        if math.abs(step) < 0.5 then
            step = angleDiff > 0 and 0.5 or -0.5
        end
        currentCameraAngle = currentCameraAngle + step
        while currentCameraAngle > 360 do currentCameraAngle = currentCameraAngle - 360 end
        while currentCameraAngle < 0 do currentCameraAngle = currentCameraAngle + 360 end
    else
        currentCameraAngle = targetCameraAngle
    end
    setCameraPositionUnfixed(0, math.rad(currentCameraAngle - 90))
end

function setTargetAngle(angle)
    targetCameraAngle = angle
    while targetCameraAngle > 360 do targetCameraAngle = targetCameraAngle - 360 end
    while targetCameraAngle < 0 do targetCameraAngle = targetCameraAngle + 360 end
end

function lookForOreNearRoute(routeX, routeY, routeZ)
    local nearbyOres = {}
    for k, v in pairs(resources) do
        local object = sampGetObjectHandleBySampId(k)
        if doesObjectExist(object) and isObjectOnScreen(object) then
            local _, ox, oy, oz = getObjectCoordinates(object)
            local distToRoute = getDistanceBetweenCoords3d(routeX, routeY, routeZ, ox, oy, oz)
            
            if distToRoute <= routeOreRadius and not isPlayerNearPosition(ox, oy, oz, 5) then
                local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
                local dist = getDistanceBetweenCoords3d(myX, myY, myZ, ox, oy, oz)
                local priority = orePriority[v] or 0
                table.insert(nearbyOres, {['position'] = {ox, oy, oz}, ['distance'] = dist, ['type'] = v, ['priority'] = priority})
            end
        end
    end
    
    if #nearbyOres > 0 then
        table.sort(nearbyOres, function(a, b) 
            if a.priority ~= b.priority then
                return a.priority > b.priority
            else
                return a.distance < b.distance
            end
        end)
        return true, nearbyOres[1].position, nearbyOres[1].type
    end
    
    return false
end

function followRecordedRoute()
    if currentRoutePoint > #recordedRoute then
        currentRoutePoint = 1
    end
    
    local point = recordedRoute[currentRoutePoint]
    local px, py, pz = getCharCoordinates(PLAYER_PED)
    local dist = getDistanceBetweenCoords3d(px, py, pz, point.x, point.y, point.z)
    
    local hasOre, orePos, oreType = lookForOreNearRoute(point.x, point.y, point.z)
    if hasOre then
        local oreDist = getDistanceBetweenCoords3d(px, py, pz, orePos[1], orePos[2], orePos[3])
        
        local oreColor = 0xFF00FF00
        local oreRadius = 1.5
        
        Draw3DCircle(orePos[1], orePos[2], orePos[3] - 0.1, oreRadius, oreColor)
        DrawTracer(px, py, pz, orePos[1], orePos[2], orePos[3], oreColor)
        
        if oreDist <= 1.5 then
            if currentMiningTarget == nil then
                currentMiningTarget = {orePos[1], orePos[2], orePos[3]}
                lastMiningAttempt = os.clock()
            end
            
            if os.clock() - lastMiningAttempt > miningTimeout then
                currentMiningTarget = nil
                lastMiningAttempt = 0
                return
            end
            
            setGameKeyState(1, 0)
            setGameKeyState(16, 0)
            setGameKeyState(21, -256)
            wait(200)
            setGameKeyState(21, 0)
            wait(500)
            currentMiningTarget = nil
            lastMiningAttempt = 0
            return
        else
            if currentMiningTarget then
                local targetDist = getDistanceBetweenCoords3d(px, py, pz, currentMiningTarget[1], currentMiningTarget[2], currentMiningTarget[3])
                if targetDist <= 1.5 and os.clock() - lastMiningAttempt <= miningTimeout then
                    local angle = getHeadingFromVector2d(currentMiningTarget[1] - px, currentMiningTarget[2] - py)
                    setTargetAngle(angle)
                    smoothCameraRotation()
                    setGameKeyState(1, -255)
                    if sprint then setGameKeyState(16, 1) end
                    return
                else
                    currentMiningTarget = nil
                end
            end
            
            local angle = getHeadingFromVector2d(orePos[1] - px, orePos[2] - py)
            setTargetAngle(angle)
            smoothCameraRotation()
            setGameKeyState(1, -255)
            if sprint then setGameKeyState(16, 1) end
            return
        end
    else
        currentMiningTarget = nil
        lastMiningAttempt = 0
    end
    
    if dist <= routeCheckDistance then
        currentRoutePoint = currentRoutePoint + 1
        if currentRoutePoint > #recordedRoute then
            currentRoutePoint = 1
        end
    end
    
    local nextPoint = recordedRoute[currentRoutePoint]
    local angle = getHeadingFromVector2d(nextPoint.x - px, nextPoint.y - py)
    setTargetAngle(angle)
    smoothCameraRotation()
    
    setGameKeyState(1, -255)
    
    if sprint then 
        setGameKeyState(16, 1)
    end
    
    if point.action == "JUMP" then
        setGameKeyState(0x20, 255)
    elseif point.action == "FORWARD" then
        setGameKeyState(0x57, -255)
    elseif point.action == "BACKWARD" then
        setGameKeyState(0x53, -255)
    elseif point.action == "LEFT" then
        setGameKeyState(0x41, -255)
    elseif point.action == "RIGHT" then
        setGameKeyState(0x44, -255)
    end
end

function DrawTracer(x1, y1, z1, x2, y2, z2, color)
    local sx1, sy1 = convert3DCoordsToScreen(x1, y1, z1)
    local sx2, sy2 = convert3DCoordsToScreen(x2, y2, z2)
    if sx1 and sx2 then
        renderDrawLine(sx1, sy1, sx2, sy2, 2, color)
    end
end

function Draw3DCircle(x, y, z, radius, color)
    local screen_x_line_old, screen_y_line_old
    for rot = 0, 360 do
        local rot_temp = math.rad(rot)
        local lineX, lineY, lineZ = radius * math.cos(rot_temp) + x, radius * math.sin(rot_temp) + y, z
        local screen_x_line, screen_y_line = convert3DCoordsToScreen(lineX, lineY, lineZ)
        if screen_x_line ~= nil and screen_x_line_old ~= nil and isPointOnScreen(lineX, lineY, lineZ, 1) then
            renderDrawLine(screen_x_line, screen_y_line, screen_x_line_old, screen_y_line_old, 2, color)
        end
        screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
    end
end

function sampev.onSetObjectMaterial(id, data)
    local object = sampGetObjectHandleBySampId(id)
    if doesObjectExist(object) and getObjectModel(object) == 3930 then
        if oreTextures[data.textureName] then
            resources[id] = oreTextures[data.textureName]
        end
    end
end

function sampev.onDestroyObject(id)
    if resources[id] then
        resources[id] = nil
    end
end

function sampev.onDisplayGameText(style, tm, text)
    if text == "stone + 1" then totalStone = totalStone + 1
    elseif text == "metal + 1" then totalMetal = totalMetal + 1
    elseif text == "silver + 1" then totalSilver = totalSilver + 1
    elseif text == "bronze + 1" then totalBronze = totalBronze + 1
    elseif text == "gold + 1" then totalGold = totalGold + 1
    elseif text == "stone + 2" then totalStone = totalStone + 2
    elseif text == "metal + 2" then totalMetal = totalMetal + 2
    elseif text == "silver + 2" then totalSilver = totalSilver + 2
    elseif text == "bronze + 2" then totalBronze = totalBronze + 2
    elseif text == "gold + 2" then totalGold = totalGold + 2
    end
end

function main()
    while not isSampAvailable() do wait(0) end
    wait(200)
    sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Скрипт загружен!', -1)
    sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Загружен маршрут: ' .. #recordedRoute .. u8' точек', -1)
    loadConfigs()
    loadConfig(mainIni.main.currentConfig)
    
    sampRegisterChatCommand('amine', function()
        WinState[0] = not WinState[0]
    end)
    
    while true do
        wait(0)
        
        
        
        if collisionEnabled then
            enableCollision()
        end
        
        if mode then
            if farmStartTime == 0 then
                farmStartTime = os.time()
            end
            
            if afkAfterHour and os.time() - farmStartTime >= 3600 and not isAfk then
                isAfk = true
                sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}АФК режим на 10 минут', -1)
                local afkStart = os.time()
                while os.time() - afkStart < afkDuration do
                    wait(1000)
                end
                isAfk = false
                farmStartTime = os.time()
                sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}АФК завершен, продолжаю работу', -1)
            end
            
            if not isAfk then
                followRecordedRoute()
            end
        else
            if farmStartTime ~= 0 then
                farmStartTime = 0
            end
        end
    end
end

local function theme()
    imgui.SwitchContext()
    local ImVec4 = imgui.ImVec4
    imgui.GetStyle().WindowPadding = imgui.ImVec2(10, 10)
    imgui.GetStyle().FramePadding = imgui.ImVec2(8, 6)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(8, 8)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(6, 6)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10
    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 0
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 0
    imgui.GetStyle().WindowRounding = 8
    imgui.GetStyle().ChildRounding = 8
    imgui.GetStyle().FrameRounding = 6
    imgui.GetStyle().ScrollbarRounding = 6
    imgui.GetStyle().GrabRounding = 4
    imgui.GetStyle().Colors[imgui.Col.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled] = ImVec4(0.60, 0.60, 0.60, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    imgui.GetStyle().Colors[imgui.Col.ChildBg] = ImVec4(0.09, 0.09, 0.09, 0.85)
    imgui.GetStyle().Colors[imgui.Col.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.96)
    imgui.GetStyle().Colors[imgui.Col.Border] = ImVec4(0.15, 0.15, 0.15, 0.60)
    imgui.GetStyle().Colors[imgui.Col.FrameBg] = ImVec4(0.10, 0.10, 0.10, 0.85)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = ImVec4(0.12, 0.12, 0.12, 0.90)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = ImVec4(0.0, 1.0, 0.5, 0.35)
    imgui.GetStyle().Colors[imgui.Col.TitleBg] = ImVec4(0.06, 0.06, 0.06, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = ImVec4(0.06, 0.06, 0.06, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = ImVec4(0.07, 0.07, 0.07, 0.60)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = ImVec4(0.15, 0.15, 0.15, 0.85)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = ImVec4(0.20, 0.20, 0.20, 0.90)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = ImVec4(0.25, 0.25, 0.25, 0.95)
    imgui.GetStyle().Colors[imgui.Col.CheckMark] = ImVec4(0.0, 1.0, 0.5, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab] = ImVec4(0.0, 1.0, 0.5, 0.75)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = ImVec4(0.0, 1.0, 0.5, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button] = ImVec4(0.10, 0.10, 0.10, 0.85)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = ImVec4(0.12, 0.12, 0.12, 0.90)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive] = ImVec4(0.0, 1.0, 0.5, 0.35)
    imgui.GetStyle().Colors[imgui.Col.Header] = ImVec4(0.0, 1.0, 0.5, 0.25)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = ImVec4(0.0, 1.0, 0.5, 0.35)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive] = ImVec4(0.0, 1.0, 0.5, 0.45)
    imgui.GetStyle().Colors[imgui.Col.Separator] = ImVec4(0.15, 0.15, 0.15, 0.60)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered] = ImVec4(0.20, 0.20, 0.20, 0.75)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive] = ImVec4(0.25, 0.25, 0.25, 0.90)
end

imgui.OnInitialize(function()
    theme()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    mainFont = imgui.GetIO().Fonts:AddFontFromFileTTF('resource/Trebucbd.ttf', 14.0, nil, glyph_ranges)
    titleFont = imgui.GetIO().Fonts:AddFontFromFileTTF('respurce/Trebucbd.ttf', 18.0, nil, glyph_ranges)
    headerFont = imgui.GetIO().Fonts:AddFontFromFileTTF('resource/Trebucbd.ttf', 16.0, nil, glyph_ranges)
end)

local function renderSectionHeader(text)
    imgui.PushFont(headerFont)
    imgui.Dummy(imgui.ImVec2(0, 5))
    imgui.TextColored(imgui.ImVec4(0.0, 1.0, 0.5, 1.0), text)
    imgui.PopFont()
    
    local p = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
    local width = imgui.GetContentRegionAvail().x
    
    dl:AddRectFilledMultiColor(
        imgui.ImVec2(p.x, p.y),
        imgui.ImVec2(p.x + width * 0.3, p.y + 2),
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 1.0, 0.5, 0.8)),
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 1.0, 0.5, 0.0)),
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 1.0, 0.5, 0.0)),
        imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 1.0, 0.5, 0.8))
    )
    
    imgui.Dummy(imgui.ImVec2(0, 12))
end

local function renderMainTab()
    imgui.SetCursorPos(imgui.ImVec2(20, 20))
    imgui.BeginGroup()
    
    renderSectionHeader(u8"Основное")
    
    if imgui.Checkbox(u8"Включить бота", imgui.new.bool(mode)) then 
        mode = not mode 
    end
    imgui.SameLine()
    if imgui.Checkbox(u8"Бег", imgui.new.bool(sprint)) then 
        sprint = not sprint 
    end
    
    imgui.Dummy(imgui.ImVec2(0, 8))
    if imgui.Checkbox(u8"АФК после часа", imgui.new.bool(afkAfterHour)) then 
        afkAfterHour = not afkAfterHour 
    end
    
    imgui.Dummy(imgui.ImVec2(0, 8))
    imgui.Text(u8"Цель добычи")
    imgui.SliderInt("##goal", SliderInt, 1, 10000)
    
    imgui.Dummy(imgui.ImVec2(0, 8))
    imgui.Text(u8"Текущая точка: " .. currentRoutePoint .. u8" из " .. #recordedRoute)
    if imgui.Button(u8"Сбросить маршрут", imgui.ImVec2(150, 25)) then
        currentRoutePoint = 1
        sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Маршрут сброшен!', -1)
    end
    
    imgui.EndGroup()
end

local function renderPriorityTab()
    imgui.SetCursorPos(imgui.ImVec2(20, 20))
    imgui.BeginGroup()
    
    renderSectionHeader(u8"Приоритеты руд")
    
    imgui.Text(u8"Камень:")
    if imgui.SliderInt("##stone", PrioritySliders[1], 1, 5) then
        orePriority[1] = PrioritySliders[1][0]
        mainIni.priority.stone = PrioritySliders[1][0]
        inicfg.save(mainIni, 'autominev2.ini')
    end
    
    imgui.Text(u8"Металл:")
    if imgui.SliderInt("##metal", PrioritySliders[2], 1, 5) then
        orePriority[2] = PrioritySliders[2][0]
        mainIni.priority.metal = PrioritySliders[2][0]
        inicfg.save(mainIni, 'autominev2.ini')
    end
    
    imgui.Text(u8"Серебро:")
    if imgui.SliderInt("##silver", PrioritySliders[3], 1, 5) then
        orePriority[3] = PrioritySliders[3][0]
        mainIni.priority.silver = PrioritySliders[3][0]
        inicfg.save(mainIni, 'autominev2.ini')
    end
    
    imgui.Text(u8"Бронза:")
    if imgui.SliderInt("##bronze", PrioritySliders[4], 1, 5) then
        orePriority[4] = PrioritySliders[4][0]
        mainIni.priority.bronze = PrioritySliders[4][0]
        inicfg.save(mainIni, 'autominev2.ini')
    end
    
    imgui.Text(u8"Золото:")
    if imgui.SliderInt("##gold", PrioritySliders[5], 1, 5) then
        orePriority[5] = PrioritySliders[5][0]
        mainIni.priority.gold = PrioritySliders[5][0]
        inicfg.save(mainIni, 'autominev2.ini')
    end
    
    imgui.EndGroup()
end

local function renderConfigTab()
    imgui.SetCursorPos(imgui.ImVec2(20, 20))
    imgui.BeginGroup()
    
    renderSectionHeader(u8"Конфигурации")
    
    imgui.Text(u8"Текущий конфиг: " .. currentConfig)
    imgui.Dummy(imgui.ImVec2(0, 8))
    
    imgui.InputText(u8"Имя конфига", configName, 256)
    
    if imgui.Button(u8"Сохранить конфиг", imgui.ImVec2(150, 25)) then
        local name = ffi.string(configName)
        if name ~= "" then
            saveConfig(name)
            loadConfigs()
            sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Конфиг сохранен: ' .. name, -1)
        end
    end
    
    imgui.SameLine()
    if imgui.Button(u8"Загрузить конфиг", imgui.ImVec2(150, 25)) then
        local name = ffi.string(configName)
        if name ~= "" then
            loadConfig(name)
            currentConfig = name
            mainIni.main.currentConfig = name
            inicfg.save(mainIni, 'autominev2.ini')
            sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Конфиг загружен: ' .. name, -1)
        end
    end
    
    imgui.Dummy(imgui.ImVec2(0, 8))
    imgui.Text(u8"Доступные конфиги:")
    
    for i, config in ipairs(configs) do
        if imgui.Button(config, imgui.ImVec2(120, 25)) then
            loadConfig(config)
            currentConfig = config
            mainIni.main.currentConfig = config
            inicfg.save(mainIni, 'autominev2.ini')
            sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Конфиг загружен: ' .. config, -1)
        end
        if i % 2 == 1 then imgui.SameLine() end
    end
    
    imgui.EndGroup()
end

local function renderCollisionTab()
    imgui.SetCursorPos(imgui.ImVec2(20, 20))
    imgui.BeginGroup()
    
    renderSectionHeader(u8"Коллизия")
    
    if imgui.Checkbox(u8"Включить коллизию", imgui.new.bool(collisionEnabled)) then 
        collisionEnabled = not collisionEnabled
        enableCollision()
        if collisionEnabled then
            sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Коллизия включена', -1)
        else
            sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Коллизия выключена', -1)
        end
    end
    
    imgui.Dummy(imgui.ImVec2(0, 8))
    imgui.Text(u8"Коллизия позволяет проходить")
    imgui.Text(u8"сквозь игроков, транспорт и объекты")
    imgui.Dummy(imgui.ImVec2(0, 8))
    imgui.Text(u8"Статус: " .. (collisionEnabled and u8"ВКЛЮЧЕНА" or u8"ВЫКЛЮЧЕНА"))
    
    imgui.EndGroup()
end

local selectedTab = 1

local newFrame = imgui.OnFrame(
    function() return WinState[0] end,
    function(player)
        local screenW, screenH = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(screenW / 2, screenH / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(800, 500), imgui.Cond.FirstUseEver)
        
        imgui.Begin("##main", WinState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
        
        local sidebarWidth = 180
        local contentWidth = 800 - sidebarWidth - 15
        
        imgui.BeginChild("##sidebar", imgui.ImVec2(sidebarWidth, 500 - 20), true)
        
        imgui.PushFont(titleFont)
        local titleSize = imgui.CalcTextSize("ECLIPSE MINE")
        imgui.SetCursorPos(imgui.ImVec2((sidebarWidth - titleSize.x) / 2, 25))
        imgui.TextColored(imgui.ImVec4(0.0, 1.0, 0.5, 1.0), "ECLIPSE MINE")
        imgui.PopFont()
        
        imgui.Dummy(imgui.ImVec2(0, 15))
        
        local tabs = {
            {id = 1, label = u8"Основное"},
            {id = 2, label = u8"Приоритеты"},
            {id = 3, label = u8"Конфиги"}, 
            {id = 4, label = u8"Коллизия"}
        }
        
        for _, tab in ipairs(tabs) do
            local isActive = (selectedTab == tab.id)
            
            imgui.SetCursorPosX(8)
            
            local buttonColor = imgui.ImVec4(0.08, 0.08, 0.08, 0.85)
            if isActive then
                buttonColor = imgui.ImVec4(0.0, 1.0, 0.5, 0.35)
            end
            
            imgui.PushStyleColor(imgui.Col.Button, buttonColor)
            imgui.PushStyleColor(imgui.Col.ButtonHovered, buttonColor)
            imgui.PushStyleColor(imgui.Col.ButtonActive, buttonColor)
            
            if imgui.Button("##tab" .. tab.id, imgui.ImVec2(sidebarWidth - 16, 38)) then
                selectedTab = tab.id
            end
            
            local p = imgui.GetItemRectMin()
            local s = imgui.GetItemRectSize()
            local wdl = imgui.GetWindowDrawList()
            
            if isActive then
                wdl:AddRectFilled(
                    imgui.ImVec2(p.x, p.y + s.y - 3),
                    imgui.ImVec2(p.x + s.x, p.y + s.y),
                    imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 1.0, 0.5, 1.0))
                )
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(p.x + 12, p.y + (s.y - imgui.GetTextLineHeight()) / 2 - 1))
            
            local textColor = isActive and imgui.ImVec4(1.0, 1.0, 1.0, 1.0) or imgui.ImVec4(0.65, 0.65, 0.65, 1.0)
            imgui.TextColored(textColor, tab.label)
            
            imgui.PopStyleColor(3)
            imgui.Dummy(imgui.ImVec2(0, 4))
        end
        
        imgui.EndChild()
        imgui.SameLine()
        
        imgui.BeginChild("##content", imgui.ImVec2(contentWidth, 500 - 20), true)
        
        imgui.PushFont(mainFont)
        
        if selectedTab == 1 then
            renderMainTab()
        elseif selectedTab == 2 then
            renderPriorityTab()
        elseif selectedTab == 3 then
            renderConfigTab()
        elseif selectedTab == 4 then
            renderCollisionTab()
        end
        
        imgui.PopFont()
        imgui.EndChild()
        imgui.End()
    end
)

imgui.OnFrame(function() return WinStats[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(getScreenResolution() / 2, select(2, getScreenResolution()) / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(350, 280), imgui.Cond.FirstUseEver)
    imgui.Begin(u8'Статистика добычи', WinStats, imgui.WindowFlags.NoResize)
    
    imgui.Spacing()
    imgui.Text(u8'Добыто ресурсов:')
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    imgui.Columns(2, 'stats_columns', false)
    imgui.SetColumnWidth(0, 180)
    
    imgui.Text(u8'Камень:')
    imgui.NextColumn()
    imgui.Text(tostring(totalStone))
    imgui.NextColumn()
    
    imgui.Text(u8'Металл:')
    imgui.NextColumn()
    imgui.Text(tostring(totalMetal))
    imgui.NextColumn()
    
    imgui.Text(u8'Серебро:')
    imgui.NextColumn()
    imgui.Text(tostring(totalSilver))
    imgui.NextColumn()
    
    imgui.Text(u8'Бронза:')
    imgui.NextColumn()
    imgui.Text(tostring(totalBronze))
    imgui.NextColumn()
    
    imgui.Text(u8'Золото:')
    imgui.NextColumn()
    imgui.Text(tostring(totalGold))
    imgui.NextColumn()
    
    imgui.Columns(1)
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    local totalMined = totalStone + totalMetal + totalSilver + totalBronze + totalGold
    imgui.Text(u8'Всего добыто: ' .. tostring(totalMined))
    local remaining = SliderInt[0] - totalMined
    imgui.Text(u8'Осталось до цели: ' .. (remaining > 0 and tostring(remaining) or '0'))
    
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    
    if imgui.Button(u8'Сбросить статистику', imgui.ImVec2(200, 30)) then 
        totalStone, totalMetal, totalSilver, totalBronze, totalGold = 0, 0, 0, 0, 0 
        sampAddChatMessage('{cc66ff}[auto-mine]: {ffffff}Статистика сброшена!', -1)
    end
    
    imgui.End()
end)
end