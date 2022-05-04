#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Im not sure if the functions with fake_read_write_buffer are correct
// pointers also not sure in readscalardata,actionwriteinitialdata.
// in readscalardata, the python bindings have `&value` instead of `*value` but this gives an error on my system
double *fake_read_write_buffer;
const int SIZE = 6;
int fake_dimensions;
int fake_mesh_id;
int *fake_ids;
int n_fake_vertices;
const char *fake_data_name;
int fake_data_id;
double *fake_bounding_box;
double *fake_coordinates;

double mean(double a, double b)
{
    return (a + b) / 2;
}

void precicec_createSolverInterface(const char *participantName,
                                    const char *configurationFileName,
                                    int solverProcessIndex,
                                    int solverProcessSize)
{
    fake_read_write_buffer = malloc(SIZE * fake_dimensions * sizeof(double));
    fake_dimensions = 3;
    fake_mesh_id = 0;
    fake_data_id = 15;
    fake_data_name = "FakeData";
    n_fake_vertices = 3;
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    for (int i = 0; i < n_fake_vertices; i++)
    {
        fake_ids[i] = i;
    }
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    for (int i = 0; i < fake_dimensions * 2; i++)
    {
        fake_bounding_box[i] = i;
    }
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    for (int i = 0; i < n_fake_vertices * fake_dimensions; i++)
    {
        fake_coordinates[i] = i;
    }
}

void precicec_createSolverInterface_withCommunicator(const char *participantName,
                                                     const char *configurationFileName,
                                                     int solverProcessIndex,
                                                     int solverProcessSize,
                                                     void *communicator)
{
    fake_read_write_buffer = malloc(SIZE * fake_dimensions * sizeof(double));
    fake_dimensions = 3;
    fake_mesh_id = 0;
    fake_data_id = 15;
    fake_data_name = "FakeData";
    n_fake_vertices = 3;
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    fake_ids = malloc(n_fake_vertices * sizeof(int));
    for (int i = 0; i < n_fake_vertices; i++)
    {
        fake_ids[i] = i;
    }
    fake_bounding_box = malloc(fake_dimensions * 2 * sizeof(double));
    for (int i = 0; i < fake_dimensions * 2; i++)
    {
        fake_bounding_box[i] = i;
    }
    fake_coordinates = malloc(n_fake_vertices * fake_dimensions * sizeof(double));
    for (int i = 0; i < n_fake_vertices * fake_dimensions; i++)
    {
        fake_coordinates[i] = i;
    }
}

double precicec_initialize() { return -1; }

void precicec_initializeData()
{
}

double precicec_advance(double computedTimestepLength)
{
    return -1;
}

void precicec_precicec_finalize()
{
}

int precicec_getDimensions()
{
    return fake_dimensions;
}

char precicec_isCouplingOngoing()
{
    return 0;
}

char precicec_isReadDataAvailable()
{
    return 0;
}

char precicec_isWriteDataRequired(double computedTimestepLength)
{
    return 0;
}

char precicec_isTimeWindowComplete()
{
    return 0;
}

char precicec_isActionRequired(const char *action)
{
    return 0;
}

void precicec_precicec_markActionFulfilled(const char *action)
{
}

char precicec_hasMesh(const char *meshName)
{
    return 0;
}

int precicec_getMeshID(const char *meshName)
{
    return fake_mesh_id;
}

char precicec_hasData(const char *dataName, int meshID)
{
    return 0;
}

int precicec_getDataID(const char *dataName, int meshID)
{
    if (meshID == fake_mesh_id && strcmp(dataName, fake_data_name) == 0)
    {
        return fake_data_id;
    }
    else
    {
        return -1;
    }
}

char precicec_hasToEvaluateSurrogateModel()
{
    return 0;
}

char precicec_hasToEvaluateFineModel()
{
    return 0;
}

// bool isMeshConnectivityRequired
// (
//   int           meshID )
// {
//   return 0;
// }

int precicec_setMeshVertex(int meshID, const double *position)
{
    return 0;
}

int precicec_getMeshVertexSize(int meshID)
{
    return n_fake_vertices;
}

void precicec_setMeshVertices(int meshID, int size, const double *positions, int *ids)
{
    assert(size == n_fake_vertices);
    for (int i = 0; i < size; i++)
    {
        ids[i] = fake_ids[i];
    }
}

void precicec_getMeshVertices(int meshID, int size, const int *ids, double *positions)
{
    for (int i = 0; i < size; i++)
    {
        positions[fake_dimensions * i] = i;
        positions[fake_dimensions * i + 1] = i + n_fake_vertices;
        positions[fake_dimensions * i + 2] = i + 2 * n_fake_vertices;
    }
}

void precicec_getMeshVertexIDsFromPositions(int meshID, int size, const double *positions, int *ids)
{
    assert(size == n_fake_vertices);
    for (int i = 0; i < size; i++)
    {
        ids[i] = fake_ids[i];
    }
}

int precicec_setMeshEdge(int meshID, int firstVertexID, int secondVertexID)
{
    return -1;
}

void precicec_setMeshTriangle(int meshID, int firstEdgeID, int secondEdgeID, int thirdEdgeID)
{
}

void precicec_setMeshTriangleWithEdges(int meshID, int firstVertexID, int secondVertexID, int thirdVertexID)
{
}

void precicec_setMeshQuad(int meshID, int firstEdgeID, int secondEdgeID, int thirdEdgeID, int fourthEdgeID)
{
}

void precicec_setMeshQuadWithEdges(int meshID, int firstVertexID, int secondVertexID, int thirdVertexID, int fourthVertexID)
{
}

void precicec_mapReadDataTo(int toMeshID)
{
}

void precicec_mapWriteDataFrom(int fromMeshID)
{
}

void precicec_writeBlockVectorData(int dataID, int size, const int *valueIndices, const double *values)
{
    for (int i = 0; i < size * precicec_getDimensions(); i++)
    {
        fake_read_write_buffer[i] = values[i];
    }
}

void precicec_writeVectorData(int dataID, int valueIndex, const double *value)
{
    for (int i = 0; i < precicec_getDimensions(); i++)
    {
        fake_read_write_buffer[i] = value[i];
    }
}

void precicec_writeBlockScalarData(int dataID, int size, const int *valueIndices, const double *values)
{
    for (int i = 0; i < size; i++)
    {
        fake_read_write_buffer[i] = values[i];
    }
}

void precicec_writeScalarData(int dataID, int valueIndex, double value)
{
    printf("%f", fake_read_write_buffer[0]);
    printf("%f", value);
    fake_read_write_buffer[0] = value;
    printf("%f", fake_read_write_buffer[0]);
}

void precicec_readBlockVectorData(int dataID, int size, const int *valueIndices, double *values)
{
    for (int i = 0; i < size * precicec_getDimensions(); i++)
    {
        values[i] = fake_read_write_buffer[i];
    }
}

void precicec_readVectorData(int dataID, int valueIndex, double *value)
{
    for (int i = 0; i < precicec_getDimensions(); i++)
    {
        value[i] = fake_read_write_buffer[i];
    }
}

void precicec_readBlockScalarData(int dataID, int size, const int *valueIndices, double *values)
{
    for (int i = 0; i < size; i++)
    {
        values[i] = fake_read_write_buffer[i];
    }
}

void precicec_readScalarData(int dataID, int valueIndex, double *value)
{
    value = &fake_read_write_buffer[0];
}

char *precicec_getVersionInformation()
{
    return "dummy";
}

const char *precicec_actionWriteInitialData()
{
    return "dummyWriteInitialData";
}

const char *precicec_actionWriteIterationCheckpoint()
{
    return "dummyWriteIteration";
}

const char *precicec_actionReadIterationCheckpoint()
{
    return "dummyReadIteration";
}
